{
  pkgs,
  config,
  inputs,
  ...
}: let
  homedir = config.home.homeDirectory;
in {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  home.packages = with pkgs; [
    age
    openssh
    sops
  ];

  # See https://github.com/Mic92/sops-nix#use-with-home-manager
  home.activation.setupEtc = config.lib.dag.entryAfter ["writeBoundary"] ''
    /run/current-system/sw/bin/systemctl start --user sops-nix
  '';

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age = {
      keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
      generateKey = false;
    };

    secrets = {
      "firefox/extensions/refined_github/personal_access_token" = {};
      "gh/hosts" = {
        path = "${config.xdg.configHome}/gh/hosts.yml";
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
      "ssh/github_main/passphrase" = {};
      "ssh/github_main/private" = {
        path = "${homedir}/.ssh/github_main";
        mode = "0600";
      };
      "ssh/github_main/public" = {
        path = "${homedir}/.ssh/github_main.pub";
        mode = "0644";
      };
      "ssh/git_main_signing/passphrase" = {};
      "ssh/git_main_signing/private" = {
        path = "${homedir}/.ssh/git_main_signing";
        mode = "0600";
      };
      "ssh/git_main_signing/public" = {
        path = "${homedir}/.ssh/git_main_signing.pub";
        mode = "0644";
      };
      "ssh/id_ed25519/passphrase" = {};
      "ssh/id_ed25519/private" = {
        path = "${homedir}/.ssh/id_ed25519";
        mode = "0600";
      };
      "ssh/id_ed25519/public" = {
        path = "${homedir}/.ssh/id_ed25519.pub";
        mode = "0644";
      };
    };
  };
}
