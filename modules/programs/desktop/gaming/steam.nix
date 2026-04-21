{ inputs, ... }:
{
  flake-file.inputs = {
    millennium = {
      url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.aspects.gaming = {
    nixos =
      { pkgs, ... }:
      {
        nixpkgs.overlays = [
          inputs.millennium.overlays.default
        ];

        programs = {
          gamescope = {
            enable = true;
            capSysNice = true;
          };

          steam = {
            enable = true;

            gamescopeSession.enable = true;
            protontricks.enable = true;

            extraCompatPackages = [
              pkgs.proton-ge-bin
            ];

            package = pkgs.millennium-steam.override {
              extraPkgs =
                p: with p; [
                  libkrb5
                  keyutils
                ];

              # Awkward workaround to let Wofi launch Steam, courtesy of
              # https://www.reddit.com/r/linux_gaming/comments/1casb3t/comment/l0u2o70
              # steam-unwrapped = pkgs.steam-unwrapped.overrideAttrs (oldAttrs: {
              #   postInstall = ''
              #     ${oldAttrs.postInstall or ""}
              #
              #     substituteInPlace $out/share/applications/steam.desktop \
              #       --replace-fail "PrefersNonDefaultGPU=true" "PrefersNonDefaultGPU=false"
              #   '';
              # });
            };
          };
        };
      };

    homeManager = {
      impermanence.directories = [
        ".steam"
        ".local/share/Steam"

        ".local/share/millennium"
        ".config/millennium"

        ".local/share/doublefine"
        ".local/share/FasterThanLight"
        ".local/share/Euro Truck Simulator 2"
        ".factorio"
      ];
    };
  };
}
