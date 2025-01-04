{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.rclone;

  log-dir = "/tmp/rclone-logs/${config.setup.username}";
in {
  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.rclone];
    systemd.user.services = builtins.listToAttrs (builtins.map (opts: {
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
            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${opts.mountpoint} ${log-dir}";
            ExecStart = lib.concatStringsSep " " [
              "${pkgs.rclone}/bin/rclone mount"
              "--vfs-cache-mode writes"
              "--log-file \"${log-dir}/${opts.remote}.log\""
              "--log-level INFO"
              "--rc"
              "--rc-addr=localhost:5572"
              "--rc-web-gui"
              "--rc-web-gui-no-open-browser"
              "${readonly}"
              "${opts.extraArgs}"
              "${opts.remote}: ${opts.mountpoint}"
            ];
            ExecStop = "${pkgs.writeShellScript "stop-rclone-mount-${lib.strings.toLower opts.remote}"
              ''
                ${pkgs.fuse}/bin/fusermount -u ${opts.mountpoint}
                ${pkgs.coreutils}/bin/rm -v "${log-dir}/${opts.remote}.log"
              ''}";
            Restart = "on-failure";
            RestartSec = "5s";
          };
        };
      })
      cfg.automounts);

    setup = {
      terminal.shellAliases.rclone = ''${pkgs.rclone}/bin/rclone --progress --bwlimit="09:00,256 23:00,off"'';
      impermanence.keepDirs = [".config/rclone"];
    };
  };
}
