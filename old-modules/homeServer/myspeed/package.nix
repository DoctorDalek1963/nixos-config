{
  buildNpmPackage,
  fetchzip,
}:
buildNpmPackage rec {
  pname = "myspeed";
  version = "1.0.9";

  src = fetchzip {
    url = "https://github.com/gnmyt/myspeed/releases/download/v${version}/MySpeed-${version}.zip";
    hash = "sha256-mQbNjBpg4yCBUTmA1xkdaPTck79D5HxO7M/WgvZwpPM=";
    stripRoot = false;
  };

  npmDepsHash = "sha256-OOAczNqA0ctFKgrHFD6zqWTrKPEVdEB7vkJ4cmGjDjk=";

  dontNpmBuild = true;
}
