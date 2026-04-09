{
  pkgs,
  lib,
  config,
  ...
}:
let
  current-age = pkgs.callPackage ./current-age/package.nix { };
in
{
  config = lib.mkIf config.wayland.windowManager.hyprland.enable {
    programs.noctalia-shell = {
      plugins = {
        sources = [
          {
            enabled = true;
            name = "Official Noctalia Plugins";
            url = "https://github.com/noctalia-dev/noctalia-plugins";
          }
        ];
        states = {
          current-age = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
        };
        version = 2;
      };

      pluginSettings = {
        current-age = {
          dateOfBirth = "2005-03-19T03:01:00";
        };
      };
    };

    setup.impermanence.keepDirs = [ ".config/noctalia/plugins" ];

    home.activation.noctalia-plugin-current-age = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${lib.getExe pkgs.rsync} -r ${current-age}/ ${config.xdg.configHome}/noctalia/plugins/current-age
    '';
  };
}
