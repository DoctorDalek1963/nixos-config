{ inputs, ... }:
{
  flake-file.inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];

  flake.aspects =
    { aspects, ... }:
    {
      system-core = {
        includes = [
          aspects.system-minimal
          aspects.ssh
        ];

        nixos =
          { pkgs, config, ... }:
          {
            imports = [
              inputs.home-manager.nixosModules.home-manager
            ];

            environment.systemPackages = with pkgs; [
              coreutils
              file
              git
              vim
              wget
            ];

            programs.nix-ld = {
              enable = true;
              libraries = with pkgs; [
                icu
                libz
                stdenv.cc.cc.lib
              ];
            };

            documentation.enable = true;

            # Show asterisks when typing password
            security.sudo.extraConfig = "Defaults pwfeedback";

            home-manager = {
              useUserPackages = true;
              useGlobalPkgs = true;
              backupFileExtension = "hm-backup";

              extraSpecialArgs.osConfig = config;
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
          };
      };
    };
}
