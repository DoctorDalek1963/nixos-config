{ inputs, ... }:
{
  flake = {
    aspects =
      { aspects, ... }:
      {
        host-alex = {
          includes = [
            aspects.system-desktop
            aspects.gaming
          ];

          homeManager = {
            programs.mangohud.settings.gpu_text = "Radeon,Mendocino";
          };
        };
      };

    nixosConfigurations.Alex-NixOS = inputs.nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";

      modules = [
        inputs.self.modules.nixos.host-alex
        {
          networking.hostName = "Alex-NixOS";
          nixpkgs.hostPlatform = system;
        }
      ];
    };
  };
}
