{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  directoryMapTmpfiles =
    lib.mergeAttrsList
    (lib.attrValues
      (lib.mapAttrs
        (user: paths:
          lib.listToAttrs (map (path:
            lib.nameValuePair "${path}" {
              d = {
                inherit user;
                group = "media";
                mode = "775";
              };
            })
          paths))
        cfgMs.directoryMap));
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
      # We can't declare mediaRoot in directoryMap because the permissions
      # service does chown recursively and there's no point changing all the
      # ownership to root and back every time
      tmpfiles.settings.mediaServer =
        {
          "${cfgMs.mediaRoot}".d = {
            user = "root";
            group = "media";
            mode = "775";
          };
        }
        // directoryMapTmpfiles;

      # TODO: Also set ownership and run periodically (but don't rerun tmpfiles-setup every time)
      services.set-permissions-for-media-server-directory-map = {
        description = "Set ownership and permissions for the mediaServer directoryMap";
        script = ''${pkgs.coreutils}/bin/chmod -R u=rwX,g=rwX,o=rX "${cfgMs.mediaRoot}"'';

        after = ["systemd-tmpfiles-setup.service"];
        requires = ["systemd-tmpfiles-setup.service"];
        wantedBy = ["multi-user.target"];

        serviceConfig.Type = "simple";
      };
    };

    setup.backup.paths = [cfgMs.mediaRoot];
  };
}
