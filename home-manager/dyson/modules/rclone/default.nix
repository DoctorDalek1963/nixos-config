{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.rclone;

  services = builtins.listToAttrs (builtins.map (opts: {
      name = "rclone-mount-${lib.strings.toLower opts.remote}";
      value = {
        Unit = {
          Description = "Mount the rclone remote ${opts.remote}";
          After = ["graphical-session.target"];
        };
        Install = {
          WantedBy = ["default.target"];
        };

        Service = let
          readonly =
            if opts.readonly
            then "--read-only"
            else "";
        in {
          Type = "simple";
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${opts.mountpoint}";
          ExecStart = "${pkgs.rclone}/bin/rclone mount --vfs-cache-mode writes ${readonly} ${opts.extraArgs} ${opts.remote}: ${opts.mountpoint}";
          ExecStop = "${pkgs.fuse}/bin/fusermount -u ${opts.mountpoint}";
          Restart = "on-failure";
          RestartSec = "10s";
        };
      };
    })
    cfg.automounts);
in {
  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.rclone];
    systemd.user.services = services;
  };
}
