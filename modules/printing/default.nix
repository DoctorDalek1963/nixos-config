{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  cfg = config.setup.printing;
in {
  config = mkMerge [
    (mkIf cfg.enable {
      # CUPS
      services.printing.enable = true;

      users.groups.lp.members = cfg.users;
    })
    (mkIf (cfg.enable && cfg.networkAutoDiscovery) {
      services.avahi = {
        enable = true;
        nssmdns = true;
        openFirewall = true;
      };
    })
    (mkIf (cfg.enable && cfg.scanning) {
      hardware.sane = {
        enable = true;
        extraBackends = [pkgs.sane-airscan];
        disabledDefaultBackends = ["escl"];
      };

      users.groups.scanner.members = cfg.users;
    })
    (mkIf (cfg.enable && cfg.specificPrinters.canonPixmaMG3250) {
      services.printing.drivers = [pkgs.cnijfilter_4_00];
    })
  ];
}
