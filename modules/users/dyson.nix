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
    };
  };
}
