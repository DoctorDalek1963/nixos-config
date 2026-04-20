{
  lib,
  config,
  ...
}:
let
  cfg = config.setup;
  cfgPass = cfg.secrets.userPasswords;
in
{
  config = lib.mkIf cfg.users.rebecca {
    users.users.rebecca = {
      uid = 1002;
      isNormalUser = true;
      description = "Rebecca";
      initialPassword = if (cfgPass.enable && cfgPass.users.rebecca) then null else "changeme";
      extraGroups = [ "networkmanager" ];
    };
  };
}
