{ inputs, ... }:
{
  flake = {
    aspects =
      { aspects, ... }:
      {
        host-alex = {
          includes = [
            aspects.system-desktop
          ];
        };
      };

    nixosConfigurations.Alex-NixOS = inputs.nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";

      modules = [
        inputs.self.modules.nixos.host-alex
        {
          networking.hostName = "Alex-NixOS";
          nixpkgs.hostPlatform = system;
          system.stateVersion = "25.05";
        }
      ];
    };
  };
}
