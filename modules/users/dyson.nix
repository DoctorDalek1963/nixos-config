{
  lib,
  config,
  ...
}: let
  cfg = config.setup;
  cfgPass = cfg.secrets.userPasswords;
in {
  config = lib.mkIf cfg.users.dyson {
    users.users.dyson = {
      uid = 1000;
      isNormalUser = true;
      description = "Dyson";

      initialPassword =
        if (cfgPass.enable && cfgPass.users.dyson)
        then null
        else "changeme";

      extraGroups = ["networkmanager" "wheel"];

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHpAf7h7CFeggGoUvI6u8pNk3CVmSZmA0xeLEW3UyAMg Dyson's id_ed25519"
      ];
    };
  };
}
