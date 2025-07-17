{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.secrets;
  keychain-enabled = cfg.enable && cfg.enableKeychain;

  ssh-keys = lib.optionals (config.home.username == "dyson") [
    "github_main"
    "git_main_signing"
    "id_ed25519"
  ];

  ssh-add-commands = map (keyname: let
    script =
      pkgs.writeShellScriptBin "cat-passphrase"
      ''cat "${config.sops.secrets."ssh/${keyname}/passphrase".path}"'';
  in ''cat "${config.sops.secrets."ssh/${keyname}/keys/${keyname}".path}" | SSH_ASKPASS="${script}/bin/cat-passphrase" SSH_ASKPASS_REQUIRE=force ssh-add -'')
  ssh-keys;

  populate-ssh-keychain-path = let
    script =
      pkgs.writeShellScriptBin "populate-ssh-keychain"
      (lib.strings.concatStringsSep "\n" ssh-add-commands);
  in "${script}/bin/populate-ssh-keychain";
in {
  config = lib.mkIf keychain-enabled {
    # Adapted from modules/programs/keychain.nix in home-manager
    programs = let
      cfg = config.programs.keychain;
      flags =
        cfg.extraFlags
        ++ lib.optional (cfg.agents != []) "--agents ${lib.strings.concatStringsSep "," cfg.agents}"
        ++ lib.optional (cfg.inheritType != null) "--inherit ${cfg.inheritType}";

      shellCommand = "${cfg.package}/bin/keychain --eval ${lib.strings.concatStringsSep " " flags} ${
        lib.strings.concatStringsSep " " cfg.keys
      }";
    in {
      keychain = {
        enable = keychain-enabled;
        keys = ssh-keys;
        extraFlags = ["--noask" "--quiet"];

        enableBashIntegration = false;
        enableZshIntegration = false;
      };

      bash.initExtra = lib.mkIf config.setup.terminal.shells.bash ''
        eval "$(SHELL=bash ${shellCommand})"
        if [ $(ssh-add -l | "${pkgs.coreutils}/bin/wc" -l) -lt ${toString (builtins.length ssh-add-commands)} ]; then
          ${populate-ssh-keychain-path} &> /dev/null
        fi
      '';

      # zsh.initExtra = lib.mkIf config.setup.shells.zsh ''
      #   eval "$(SHELL=zsh ${shellCommand})"
      #   ${populate-ssh-keychain-path} &> /dev/null
      # '';
    };
  };
}
