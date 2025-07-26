{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.terminal;
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.tools.direnv {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;

        config.global.hide_env_diff = true;
      };

      setup = {
        impermanence.keepDirs = [ ".local/share/direnv" ];
        terminal.shellAliases.ndr = "nix-direnv-reload";
      };
    })
    (lib.mkIf (cfg.tools.direnv && cfg.shells.bash) {
      programs = {
        # TODO (direnv 2.37): Once https://github.com/direnv/direnv/pull/1439
        # is merged and in a release, we can remove this patch
        direnv = {
          package = pkgs.direnv.overrideAttrs (oldAttrs: {
            patches = (oldAttrs.patches or [ ]) ++ [ ./direnv-bash-hook.patch ];
          });

          enableBashIntegration = false;
        };

        # We need direnv to hook into ble.sh before Starship, so we don't want
        # the `mkAfter` from home-manager's implementation
        bash.initExtra = ''
          eval "$(${lib.getExe config.programs.direnv.package} hook bash)"
        '';
      };
    })
  ];
}
