{ self, inputs, ... }:
{
  flake.aspects.system-minimal = {
    nixos =
      { pkgs, config, ... }:
      {
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

        programs.nix-ld = {
          enable = true;
          libraries = with pkgs; [
            icu
            libz
            stdenv.cc.cc.lib
          ];
        };

        environment.systemPackages = with pkgs; [
          coreutils
          file
          git
          vim
          wget
        ];

        # Show asterisks when typing password
        security.sudo.extraConfig = "Defaults pwfeedback";

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

    homeManager =
      { lib, config, ... }:
      {
        home = {
          # inherit (config.setup) username;
          homeDirectory = "/home/${config.home.username}";

          stateVersion = "25.11";

          file = {
            ".inputrc".text = ''
              $include /etc/inputrc
              "\C-H": backward-kill-word
            '';
            ".XCompose".text = ''
              include "%L"
              <Multi_key> <b> <c> : "∵" # because
              <Multi_key> <t> <f> : "∴" # therefore
            '';
          };
        };

        targets.genericLinux.enable = lib.mkDefault false;

        xdg = {
          enable = true;

          userDirs =
            let
              home = "${config.home.homeDirectory}";
            in
            {
              enable = true; # TODO: Only when graphical?
              createDirectories = true;
              setSessionVariables = true;

              documents = "${home}/Documents";
              download = "${home}/Downloads";
              music = "${home}/Music";
              pictures = "${home}/Pictures";
              videos = "${home}/Videos";

              desktop = null;
              publicShare = null;
              templates = null;
            };
        };
      };
  };
}
