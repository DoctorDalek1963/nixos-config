{ inputs, ... }:
{
  imports = [
    inputs.flake-file.flakeModules.dendritic

    inputs.flake-parts.flakeModules.modules # exposes flake.modules as output
    inputs.flake-aspects.flakeModule
  ];

  flake-file.inputs = {
    flake-file.url = "github:vic/flake-file";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-aspects.url = "github:vic/flake-aspects";
  };
}
