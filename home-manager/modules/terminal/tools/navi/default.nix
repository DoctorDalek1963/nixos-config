{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.terminal;

  cheat-files = lib.optional config.setup.misc.programs.mediaCuration ./media.cheat;

  cheat-drvs = map (
    f:
    pkgs.stdenv.mkDerivation {
      name = "navi-cheat-${builtins.baseNameOf f}";
      dontUnpack = true;
      dontBuild = true;
      installPhase = "install -Dm755 ${f} $out/${builtins.baseNameOf f}";
    }
  ) cheat-files;
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.tools.navi {
      setup.terminal.shellAliases.na = "navi";

      programs.navi = {
        enable = true;
        settings = {
          cheats.paths = [
            "${pkgs.symlinkJoin {
              name = "navi-cheats";
              paths = cheat-drvs;
            }}"
          ];
        };
      };
    })
    (lib.mkIf (cfg.tools.navi && cfg.shells.bash) {
      # We have to do it differently so that it works with ble.sh
      programs = {
        navi.enableBashIntegration = false;

        bash.initExtra =
          # bash
          ''
            _navi_call() {
                local result="$(navi "$@" </dev/tty)"
                printf "%s" "$result"
            }

            ble/widget/navi() {
                local -r input="$_ble_edit_str"
                local -r last_command="$(echo "''${input}" | navi fn widget::last_command)"

                if [ -z "''${last_command}" ]; then
                    local -r output="$(_navi_call --print)"
                else
                    local -r find="''${last_command}_NAVIEND"
                    local -r replacement="$(_navi_call --print --query "$last_command")"
                    local output="$input"

                    if [ -n "$replacement" ]; then
                        output="''${input}_NAVIEND"
                        output="''${output//$find/$replacement}"
                    fi
                fi

                ble-edit/content/reset "$output"
                _ble_edit_ind=''${#output}
            }

            ble-bind -m emacs -f 'C-n' navi
          '';
      };
    })
  ];
}
