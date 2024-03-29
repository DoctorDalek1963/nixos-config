{
  pkgs,
  lib,
  config,
  ...
}: let
  homedir = config.home.homeDirectory;
  cfg = config.setup;

  secretsIf = condition: secrets:
    if condition
    then secrets
    else {};

  firefox-secrets =
    secretsIf cfg.firefox.enable
    {
      "firefox/extensions/refined_github/personal_access_token" = {};
    };
in {
  config = lib.mkIf cfg.secrets.enable {
    home.packages = with pkgs; [
      age
      openssh
      sops
    ];

    sops = {
      defaultSopsFile = ../../sops-secrets/secrets.yaml;
      age = {
        keyFile = "/etc/nixos/home-manager/dyson/sops-secrets/key.txt";
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
        // firefox-secrets;
    };
  };
}
