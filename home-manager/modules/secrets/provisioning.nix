{
  pkgs,
  lib,
  config,
  ...
}: let
  homedir = config.home.homeDirectory;
  cfg = config.setup;

  uid =
    {
      dyson = "1000";
      pi = "1001";
      rebecca = "1002";
    }
    .${config.home.username};

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

  firefox-secrets = secretsIf cfg.firefox.enable {
    "firefox/extensions/refined_github/personal_access_token" = {};
  };

  irc-secrets = secretsIf cfg.miscPrograms.hexchat {
    "irc/libera/password" = {mode = "0400";};
    "irc/oftc/password" = {mode = "0400";};
  };
in {
  config = lib.mkIf cfg.secrets.enable {
    home.packages = [pkgs.openssh];

    sops = {
      defaultSopsFile = ../../sops-secrets/secrets.yaml;

      # FIXME: This is bad because we don't want to hardcode the UID, but
      # sops-nix seems to have no way of knowing where it will link things at
      # build time, so it can't reference paths to secrets which are not
      # symlinked elsewhere, like SSH key passphrases. See ./keychain.nix for
      # why we need this.
      defaultSymlinkPath = "/run/user/${uid}/secrets";
      defaultSecretsMountPoint = "/run/user/${uid}/secrets.d";

      age = {
        keyFile = "/etc/nixos/home-manager/sops-secrets/key.txt";
        generateKey = false;
      };

      secrets =
        {
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
        // firefox-secrets
        // irc-secrets;
    };
  };
}
