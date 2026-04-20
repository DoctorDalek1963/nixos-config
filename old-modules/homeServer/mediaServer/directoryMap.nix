{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  directoryMapTmpfiles = lib.mergeAttrsList (
    lib.attrValues (
      lib.mapAttrs (
        user: paths:
        lib.listToAttrs (
          map (
            path:
            lib.nameValuePair "${path}" {
              d = {
                inherit user;
                group = "media";
                mode = "775";
              };
            }
          ) paths
        )
      ) cfgMs.directoryMap
    )
  );
in
{
  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    systemd = {
      # We can't declare mediaRoot in directoryMap because the permissions
      # service does chown recursively and there's no point changing all the
      # ownership to root and back every time
      tmpfiles.settings.mediaServer = {
        "${cfgMs.mediaRoot}".d = {
          user = "root";
          group = "media";
          mode = "775";
        };
      }
      // directoryMapTmpfiles;

      services.set-permissions-for-media-server-directory-map = {
        description = "Set ownership and permissions for the mediaServer directoryMap";
        script =
          let
            commands = lib.flatten (
              lib.mapAttrsToList (
                user: paths:
                map (path: ''
                  chown -R ${user}:media "${path}"
                  chmod -R u=rwX,g=rwX,o=rX "${path}"
                '') paths
              ) cfgMs.directoryMap
            );

            shellApp = pkgs.writeShellApplication {
              name = "set-permissions-for-media-server-directory-map";
              runtimeInputs = [ pkgs.coreutils ];
              text = ''
                chmod -R u=rwX,g=rwX,o=rX "${cfgMs.mediaRoot}"

                ${lib.concatStringsSep "\n" commands}
              '';
            };
          in
          "${shellApp}/bin/set-permissions-for-media-server-directory-map";

        after = [ "systemd-tmpfiles-setup.service" ];
        wants = [ "systemd-tmpfiles-setup.service" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig.Type = "simple";
      };

      timers.set-permissions-for-media-server-directory-map = {
        timerConfig = {
          OnCalendar = "*:00"; # Every hour
          Unit = "set-permissions-for-media-server-directory-map.service";
        };

        wantedBy = [ "timers.target" ];
      };
    };

    # Allow anyone in the media group to manually trigger a directory map
    security.sudo.extraRules = [
      {
        commands = [
          {
            command = "/run/current-system/sw/bin/systemctl start set-permissions-for-media-server-directory-map.service";
            options = [ "NOPASSWD" ];
          }
        ];
        groups = [ "media" ];
      }
    ];
  };
}
