#!/usr/bin/env nix-shell
//! ```cargo
//! [dependencies]
//! anyhow = "1.0.98"
//! async-process = "2.3.0"
//! futures-lite = "2.6.0"
//! json = "0.12.4"
//! lazy_static = "1.5.0"
//! reqwest = "0.12.15"
//! reqwest-leaky-bucket = "0.4.0"
//! reqwest-middleware = "0.4.2"
//! tokio = { version = "1.45.0", features = ["macros", "rt-multi-thread"] }
//! tracing = "0.1.41"
//! tracing-subscriber = { version = "0.3.19", features = ["env-filter"] }
//! ```
/*
#! nix-shell -i rust-script -p rust-script -p cargo -p openssl -p pkg-config
*/

use anyhow::Context;
use async_process::Command;
use futures_lite::io::AsyncWriteExt;
use std::{
    collections::{HashMap, HashSet},
    sync::{Arc, OnceLock},
    time::Duration,
};
use tokio::sync::RwLock;
use tracing::{Instrument, debug, info, trace};

/// The directory of the flake.
static FLAKE_DIR: OnceLock<String> = OnceLock::new();

lazy_static::lazy_static! {
    /// Cache URLs and the presence of the paths. True means the substituter has the path, false means
    /// it doesn't.
    static ref URL_CACHE: Arc<RwLock<HashMap<String, bool>>> = Arc::new(RwLock::new(HashMap::new()));
}

/// Return a list of all substituters (caches) for this system.
async fn get_subsituters(system_name: &str) -> anyhow::Result<Vec<String>> {
    debug!("Getting substituters with nix eval");
    let subs_output = Command::new("nix")
        .arg("eval")
        .arg(format!(
            "{flake_dir}#nixosConfigurations.\"{system_name}\".config.nix.settings.substituters",
            flake_dir = FLAKE_DIR.get().unwrap()
        ))
        .arg("--json")
        .output()
        .await?
        .stdout;

    let subs_output = core::str::from_utf8(&subs_output)?;
    let subs_strings = match json::parse(subs_output).with_context(|| {
        format!("While parsing JSON from nix eval settings, subs_output={subs_output:?}")
    })? {
        json::JsonValue::Array(strings) => strings
            .into_iter()
            .map(|x| match x {
                json::JsonValue::String(s) => Ok(s),
                json::JsonValue::Short(s) => Ok(String::from(s)),
                _ => Err(anyhow::anyhow!(
                    "JSON list of substituters must be only strings, not {x:?}"
                )),
            })
            .collect::<Result<Vec<String>, _>>()?,
        _ => Err(anyhow::anyhow!("JSON substituters output must be list"))?,
    };

    info!("Found {} substituters", subs_strings.len());

    Ok(subs_strings)
}

/// Return the set of required paths for this system which are not present in any cache.
#[tracing::instrument]
async fn get_missing_paths_for_system(system_name: String) -> anyhow::Result<HashSet<String>> {
    debug!("Getting drvPath with nix build");
    let build_output = Command::new("nix")
        .arg("build")
        .arg(format!(
            "{flake_dir}#nixosConfigurations.\"{system_name}\".config.system.build.toplevel",
            flake_dir = FLAKE_DIR.get().unwrap()
        ))
        .args(["--keep-going", "--json"])
        .output()
        .await?
        .stdout;

    let build_output = core::str::from_utf8(&build_output)?;
    let drv_path = match json::parse(build_output).with_context(|| {
        format!("While parsing JSON from nix build, build_output={build_output:?}")
    })? {
        json::JsonValue::Array(objects) => {
            let object = objects.first().cloned().ok_or(anyhow::anyhow!(
                "Build objects list must have first element"
            ))?;

            match object {
                json::JsonValue::Object(obj) => {
                    let drv_path_val = obj
                        .get("drvPath")
                        .ok_or(anyhow::anyhow!(
                            "First object in build objects list must have \"drvPath\" key"
                        ))?
                        .clone();

                    match drv_path_val {
                        json::JsonValue::String(x) => x,
                        json::JsonValue::Short(x) => String::from(x),
                        _ => Err(anyhow::anyhow!(
                            "JSON value for key \"drvPath\" must be string"
                        ))?,
                    }
                }
                _ => Err(anyhow::anyhow!(
                    "First element in build objects list must be object"
                ))?,
            }
        }
        _ => Err(anyhow::anyhow!("JSON build output must be list"))?,
    };

    debug!("{system_name} has drvPath {drv_path}");

    let all_paths_stdout: Vec<u8> = Command::new("nix-store")
        .args(["--query", "--requisites", "--include-outputs"])
        .arg(drv_path)
        .output()
        .await?
        .stdout;

    let all_paths: Vec<String> = core::str::from_utf8(&all_paths_stdout)?
        .split("\n")
        .filter(|s| !str::is_empty(s))
        .map(String::from)
        .collect();

    info!("{system_name} has {} total paths", all_paths.len());

    let substituters = get_subsituters(&system_name).await?;
    let mut missing_paths: HashSet<String> = HashSet::new();
    missing_paths.extend(all_paths.iter().cloned());

    let mut join_set = tokio::task::JoinSet::new();
    for substituter in substituters {
        join_set.spawn(
            test_paths_in_sub(substituter, all_paths.clone()).instrument(tracing::Span::current()),
        );
    }

    while let Some(thing) = join_set.join_next().await {
        let this_subs_missing_paths = thing??;

        let intersection: HashSet<String> = missing_paths
            .intersection(&this_subs_missing_paths)
            .cloned()
            .collect();

        missing_paths = intersection;
    }

    Ok(missing_paths.into_iter().collect())
}

/// Test all the given paths against this substituter to see which are available.
#[tracing::instrument(skip(paths))]
async fn test_paths_in_sub(
    substituter: String,
    paths: Vec<String>,
) -> anyhow::Result<HashSet<String>> {
    info!("Testing {} paths against {substituter}", paths.len());

    let mut missing_paths: HashSet<&str> = HashSet::new();
    let total = paths.len();
    let mut timeouts: usize = 0;

    let client = reqwest_middleware::ClientBuilder::new(
        reqwest::ClientBuilder::new()
            .read_timeout(Duration::from_secs(2))
            .build()?,
    )
    .with(reqwest_leaky_bucket::rate_limit_all(
        reqwest_leaky_bucket::leaky_bucket::RateLimiter::builder()
            .max(500)
            .initial(0)
            .refill(100)
            .fair(false)
            .interval(Duration::from_secs(3))
            .build(),
    ))
    .build();

    for (idx, path) in paths.iter().enumerate() {
        let url = format!("{substituter}/{hash}.narinfo", hash = &path[11..43]);

        let cache_hit = URL_CACHE.read().await.get(&url).copied();
        match cache_hit {
            Some(true) => {}
            Some(false) => {
                missing_paths.insert(path);
            }
            None => {
                trace!("Getting {url}");
                match client.get(&url).send().await {
                    Ok(resp) => {
                        let missing = resp.status() == reqwest::StatusCode::NOT_FOUND;

                        URL_CACHE.write().await.insert(url, !missing);
                        if missing {
                            missing_paths.insert(path);
                        }
                    }
                    Err(e) => {
                        if e.is_timeout() {
                            debug!("Timeout from {url}");
                            timeouts += 1;
                            missing_paths.insert(path);
                        } else {
                            Err(e)?;
                        }
                    }
                };
            }
        }

        if (idx + 1) % 250 == 0 {
            debug!("Done {}/{total} network requests", idx + 1);
        }
    }

    debug!("Got {timeouts} timeouts in {total} paths from {substituter}");

    Ok(missing_paths.into_iter().map(String::from).collect())
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    use tracing_subscriber::{EnvFilter, filter::FilterFn, fmt, prelude::*};

    tracing_subscriber::registry()
        .with(fmt::layer().with_filter(FilterFn::new(|metadata| {
            metadata.target() == env!("CARGO_PKG_NAME") // Just this crate
        })))
        .with(EnvFilter::from_default_env())
        .init();

    let mut args: Vec<_> = std::env::args().collect();
    args.reverse();
    args.pop();

    FLAKE_DIR
        .set(
            args.pop()
                .ok_or(anyhow::anyhow!("First argument must be flake directory"))?,
        )
        .map_err(|s| anyhow::anyhow!("FLAKE_DIR OnceLock already contained string {s:?}"))?;

    if args.is_empty() {
        return Err(anyhow::anyhow!(
            "Arguments after first must be names of systems to build and push"
        ));
    }

    let mut join_set = tokio::task::JoinSet::new();
    for system_name in args {
        join_set.spawn(get_missing_paths_for_system(system_name));
    }

    let mut paths_to_push = HashSet::new();
    while let Some(thing) = join_set.join_next().await {
        let paths_for_system = thing??;
        paths_to_push.extend(paths_for_system);
    }

    info!("Running cachix push with {} paths", paths_to_push.len());
    let cachix_cmd = Command::new("cachix")
        .arg("push")
        .arg("doctordalek1963")
        .stdin(async_process::Stdio::piped())
        .spawn()?;

    let mut cachix_stdin = cachix_cmd
        .stdin
        .ok_or(anyhow::anyhow!("Cachix command must have piped stdin"))?;

    for path in paths_to_push {
        cachix_stdin.write(path.as_bytes()).await?;
        cachix_stdin.write(b"\n").await?;
    }
    info!("Finished pushing paths to cachix!");

    Ok(())
}
