{ inputs, ... }:
{
  flake.aspects =
    { aspects, ... }:
    {
      nixpkgs = {
        includes = [
          aspects.nix-conf
          aspects.substituters
        ];

        generic = {
          nixpkgs = {
            overlays = [
              # Access unstable packages through pkgs.unstable
              # (_final: _prev: {
              #   unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
              # })
              inputs.nur.overlays.default
            ];

            config = {
              # These are lists of allowed unfree and insecure packages respectively.
              # They are allowed on any host, but they're only actually installed
              # by certain modules.
              # TODO: Split this into modules
              allowUnfreePackages = [
                # === System-wide
                # Gaming
                "steam"
                "steam-unwrapped"
                "xone-dongle-firmware" # Needed for xone driver

                # Printing
                "cnijfilter" # Canon Pixma driver

                # Proprietary Nvidia drivers
                "nvidia-x11"
                "nvidia-settings"

                # Automated transcoding on home server
                "fileflows"

                # === home-manager
                "discord"
                "geogebra"
                "libsciter" # For RustDesk
                "obsidian"
                "zoom"

                # Firefox extensions
                "dashlane"
                "enhancer-for-youtube"
                "tweaks-for-youtube"
                "youtube-recommended-videos" # Unhook

                # Microsoft fonts
                "corefonts"
                "vista-fonts"
              ];

              # TODO: Split this into modules
              permittedInsecurePackages = [
                # Used by Eddie, the UI for AirVPN
                "dotnet-sdk-6.0.428"
                "dotnet-runtime-6.0.36"

                # HTTP proxy used on home server. It's okay because it's only
                # accessible to devices on my tailnet and not the public internet
                "squid-7.0.1"
              ];
            };
          };
        };
      };
    };
}
