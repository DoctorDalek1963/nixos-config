{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: let
  homedir = config.home.homeDirectory;
  cfg = config.setup;

  inherit (osConfig.users.users.${config.home.username}) uid;

  secretsIf = condition: secrets:
    if condition
    then secrets
    else {};

  git-ssh-secrets = secretsIf cfg.terminal.tools.git {
    "ssh/github_main/passphrase" = {};
    "ssh/github_main/keys/github_main" = {
      path = "${homedir}/.ssh/github_main";
      mode = "0600";
    };
    "ssh/github_main/keys/github_main.pub" = {
      path = "${homedir}/.ssh/github_main.pub";
      mode = "0644";
    };

    "ssh/git_main_signing/passphrase" = {};
    "ssh/git_main_signing/keys/git_main_signing" = {
      path = "${homedir}/.ssh/git_main_signing";
      mode = "0600";
    };
    "ssh/git_main_signing/keys/git_main_signing.pub" = {
      path = "${homedir}/.ssh/git_main_signing.pub";
      mode = "0644";
    };
  };

  irc-secrets = secretsIf cfg.misc.programs.hexchat {
    "irc/libera/password" = {mode = "0400";};
    "irc/oftc/password" = {mode = "0400";};
  };
in {
  config = lib.mkIf cfg.secrets.enable {
    home.packages = [pkgs.openssh];

    setup.impermanence.keepFiles = [
      ".config/sops/age/keys.txt"
      ".ssh/known_hosts"
    ];

    sops = {
      defaultSopsFile = ../../sops-secrets/secrets.yaml;

      # This is suboptimal because we don't want to hardcode the UID, but
      # sops-nix seems to have no way of knowing where it will link things at
      # build time, so it can't reference paths to secrets which are not
      # symlinked elsewhere, like SSH key passphrases. See ./keychain.nix for
      # why we need this.
      defaultSymlinkPath = "/run/user/${toString uid}/secrets";
      defaultSecretsMountPoint = "/run/user/${toString uid}/secrets.d";

      age = {
        keyFile = "/etc/nixos/home-manager/sops-secrets/key.txt";
        generateKey = false;
      };

      secrets =
        {
          "nix/nixconf" = {
            path = "${homedir}/.config/nix/nix.conf";
            mode = "0600";
          };

          "ssh/authorized_keys" = {
            path = "${homedir}/.ssh/authorized_keys";
            mode = "0600";
          };

          "ssh/config" = {
            path = "${homedir}/.ssh/config";
            mode = "0644";
          };

          "ssh/id_ed25519/passphrase" = {};
          "ssh/id_ed25519/keys/id_ed25519" = {
            path = "${homedir}/.ssh/id_ed25519";
            mode = "0600";
          };
          "ssh/id_ed25519/keys/id_ed25519.pub" = {
            path = "${homedir}/.ssh/id_ed25519.pub";
            mode = "0644";
          };
        }
        // git-ssh-secrets
        // irc-secrets;
    };
  };
}
