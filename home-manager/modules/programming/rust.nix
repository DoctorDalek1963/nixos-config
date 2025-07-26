{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.setup.programming.rust {
    home.file.".cargo/config.toml".text = ''
      [alias]
      a = "add"
      b = "build"
      br = "build --release"
      c = "check"
      i = "install"
      n = "new"
      r = "run"
      rr = "run --release"
      t = "test"
      tr = "test --release"
      up = "update"
    '';

    xdg.configFile."evcxr/init.evcxr".text = "use std::mem::{size_of, transmute};";

    setup = {
      impermanence = {
        keepFiles = [ ".cargo/.global-cache" ];
        keepDirs = [ ".cargo/registry" ];
      };

      terminal.shellAliases = {
        ca = "cargo";
        rs = "${pkgs.evcxr}/bin/evcxr";
        clippy = "cat ${./clippy.conf} | xargs cargo clippy --all-features --";
      };
    };
  };
}
