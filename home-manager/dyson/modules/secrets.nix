{
  sops-nix,
  config,
  homedir,
  ...
}: {
  imports = [sops-nix.homeManagerModules.sops];

  sops = {
    defaultSopsFile = ./../secrets/secrets.yaml;
    age = {
      keyFile = "${config.xdg.configHome}/sops/age/sops-nix.txt";
      generate = false;
    };

    secrets = {
      "ssh/github_main/passphrase" = {};
      "ssh/github_main/private" = {
        path = "${homedir}/.ssh/github_main";
      };
      "ssh/github_main/public" = {
        path = "${homedir}/.ssh/github_main.pub";
      };
    };
  };
}
