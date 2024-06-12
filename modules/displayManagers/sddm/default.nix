{
  lib,
  config,
  ...
}: let
  cfg = config.setup.displayManagers.sddm;
in {
  config = lib.mkIf cfg.enable {
    services.displayManager.sddm = {
      enable = true;
      theme = lib.mkIf (cfg.theme != null) "${cfg.theme}";
    };
  };
}
