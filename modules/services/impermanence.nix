{ inputs, ... }:
{
  flake-file.inputs = {
    impermanence.url = "github:nix-community/impermanence";
  };

  flake.aspects.impermanence = {
    nixos = {
      imports = [
        inputs.impermanence.nixosModules.impermanence
      ];

      # TODO
    };
  };
}
