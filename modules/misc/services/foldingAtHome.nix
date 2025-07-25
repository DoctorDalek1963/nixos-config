{
  lib,
  config,
  ...
}: let
  cfg = config.setup.misc.services.foldingAtHome;
  directory = "/var/lib/foldingathome";
in {
  config = lib.mkIf cfg.enable {
    sops.secrets."foldingAtHome/config.xml".mode = "0444";

    services.foldingathome = {
      enable = true;
      daemonNiceLevel = 5;
      extraArgs = [
        "--config=${config.sops.secrets."foldingAtHome/config.xml".path}"
        "--machine-name=${config.setup.hostname}"
      ];
    };

    # The default config uses a dynamic user but that doesn't work for me and I
    # have no idea why, so I just override the systemd service with a static user

    # FIXME: Currently this runs the service as root, which is obviously very
    # bad because Folding@home downloads and runs untrusted binary blobs, so
    # this is momumentally insecure, but at least it works

    # users = {
    #   users.foldingathome = {
    #     isSystemUser = true;
    #     group = "foldingathome";
    #   };
    #   groups.foldingathome = {};
    # };

    # setup.impermanence.keepDirs = [
    #   {
    #     inherit directory;
    #     user = "foldingathome";
    #     group = "foldingathome";
    #     mode = "u=rwx,g=rx,o=rx";
    #   }
    # ];

    systemd = {
      services.foldingathome. serviceConfig = {
        DynamicUser = lib.mkForce false;
        # User = lib.mkForce "foldingathome";
        # Group = lib.mkForce "foldingathome";

        StateDirectory = "foldingathome";
        WorkingDirectory = lib.mkForce directory;
      };
    };
  };
}
