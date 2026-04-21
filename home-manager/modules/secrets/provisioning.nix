{
  pkgs,
  lib,
  config,
  ...
}:
let
  homedir = config.home.homeDirectory;
  cfg = config.setup;

  isDyson = config.home.username == "dyson";

  ssh-key-secrets = lib.optionalAttrs isDyson {
    "ssh/id_ed25519/passphrase" = { };
    "ssh/id_ed25519/keys/id_ed25519" = {
      path = "${homedir}/.ssh/id_ed25519";
      mode = "0600";
    };
    "ssh/id_ed25519/keys/id_ed25519.pub" = {
      path = "${homedir}/.ssh/id_ed25519.pub";
      mode = "0644";
    };
  };

  git-ssh-secrets = lib.optionalAttrs (isDyson && cfg.terminal.tools.git) {
    "ssh/github_main/passphrase" = { };
    "ssh/github_main/keys/github_main" = {
      path = "${homedir}/.ssh/github_main";
      mode = "0600";
    };
    "ssh/github_main/keys/github_main.pub" = {
      path = "${homedir}/.ssh/github_main.pub";
      mode = "0644";
    };

    "ssh/git_main_signing/passphrase" = { };
    "ssh/git_main_signing/keys/git_main_signing" = {
      path = "${homedir}/.ssh/git_main_signing";
      mode = "0600";
    };
    "ssh/git_main_signing/keys/git_main_signing.pub" = {
      path = "${homedir}/.ssh/git_main_signing.pub";
      mode = "0644";
    };
  };

  irc-secrets = lib.optionalAttrs (isDyson && cfg.misc.programs.hexchat) {
    "irc/libera/password" = {
      mode = "0400";
    };
    "irc/oftc/password" = {
      mode = "0400";
    };
  };
in
{
  config = lib.mkIf cfg.secrets.enable {
    home = {
      packages = [ pkgs.openssh ];
    };

    setup.impermanence.keepFiles = [
      ".config/sops/age/keys.txt"
      ".ssh/known_hosts"
    ];

    sops = {
      secrets = {
        "nix/nixconf" = {
          # Acces token, needed in system-core, not minimal
          path = "${homedir}/.config/nix/nix.conf";
          mode = "0600";
        };

        "ssh/config" = {
          path = "${homedir}/.ssh/config";
          mode = "0644";
        };
      }
      // ssh-key-secrets
      // git-ssh-secrets
      // irc-secrets;
    };
  };
}
