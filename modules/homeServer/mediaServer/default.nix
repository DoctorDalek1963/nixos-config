{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  imports = [
    ./torrenting
    ./servarrConfig
    ./books
    ./music
    ./video
    ./fileflows

    ./prowlarr.nix
  ];

  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    users.groups.media = {
      members = lib.optional (cfg.manager != null) cfg.manager;
    };

    systemd = {
      tmpfiles.settings.mediaRoot."${cfgMs.mediaRoot}".d = {
        user = "root";
        group = "media";
        mode = "775";
      };

      services.chmod-media-root = {
        description = "Chmod mediaRoot";
        script = ''${pkgs.coreutils}/bin/chmod -R u=rwX,g=rwX,o=rX "${cfgMs.mediaRoot}"'';

        after = ["systemd-tmpfiles-setup.service"];
        requires = ["systemd-tmpfiles-setup.service"];
        wantedBy = ["multi-user.target"];

        serviceConfig.Type = "oneshot";
      };
    };

    setup.backup.paths = [cfgMs.mediaRoot];
  };
}
