{
  sops-nix,
  config,
  homedir,
  ...
}: {
  imports = [sops-nix.homeManagerModules.sops];

  # See https://github.com/Mic92/sops-nix#use-with-home-manager
  home.activation.setupEtc = config.lib.dag.entryAfter ["writeBoundary"] ''
    /run/current-system/sw/bin/systemctl start --user sops-nix
  '';

  sops = {
    defaultSopsFile = ./../secrets/secrets.yaml;
    age = {
      keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
      generateKey = false;
    };

    secrets = {
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
