{ self, inputs, ... }:
{
  flake.aspects =
    { aspects, ... }:
    {
      system-minimal = {
        includes = [
          aspects.nixpkgs
        ];

        nixos =
          {
            lib,
            config,
            modulesPath,
            ...
          }:
          {
            imports = [
              (modulesPath + "/installer/scan/not-detected.nix")
            ];

            time.timeZone = "Europe/London";

            i18n = {
              defaultLocale = "en_GB.UTF-8";
              extraLocaleSettings = {
                LC_ADDRESS = "en_GB.UTF-8";
                LC_IDENTIFICATION = "en_GB.UTF-8";
                LC_MEASUREMENT = "en_GB.UTF-8";
                LC_MONETARY = "en_GB.UTF-8";
                LC_NAME = "en_GB.UTF-8";
                LC_NUMERIC = "en_GB.UTF-8";
                LC_PAPER = "en_GB.UTF-8";
                LC_TELEPHONE = "en_GB.UTF-8";
                LC_TIME = "en_GB.UTF-8";
              };
            };

            # Use British keyboard in TTYs
            console.keyMap = "uk";

            # Don't build any docs locally
            documentation.enable = lib.mkDefault false;

            system =
              let
                nixosVersion = builtins.concatStringsSep "." [
                  config.system.nixos.release
                  (builtins.substring 0 8 inputs.nixpkgs.sourceInfo.lastModifiedDate)
                  inputs.nixpkgs.sourceInfo.shortRev
                ];

                configurationRevision = self.sourceInfo.shortRev or self.sourceInfo.dirtyShortRev;

                buildVersion = builtins.concatStringsSep "." [
                  (builtins.substring 0 8 self.sourceInfo.lastModifiedDate)
                  configurationRevision
                ];
              in
              {
                inherit configurationRevision;

                stateVersion = "25.11";

                nixos.label = builtins.concatStringsSep "-" (
                  config.system.nixos.tags
                  ++ [ nixosVersion ]
                  ++ [
                    "build"
                    buildVersion
                  ]
                );
              };
          };
      };
    };
}
