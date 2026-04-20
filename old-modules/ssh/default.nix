{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.ssh;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.sshfs ];

    programs.mosh.enable = cfg.mosh;

    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    programs.ssh.knownHostsFiles = [ ./github.keys ];

    setup.impermanence.keepFiles = [
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };
}
