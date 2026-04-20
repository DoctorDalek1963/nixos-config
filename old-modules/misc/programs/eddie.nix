{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.misc.programs.eddie;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.eddie ];

    users.groups.eddie.members = cfg.users;

    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
          if (
              subject.isInGroup("eddie") &&
              action.id === "org.airvpn.eddie.ui.elevated.policy"
          ) {
              return polkit.Result.YES;
          }
      });
    '';
  };
}
