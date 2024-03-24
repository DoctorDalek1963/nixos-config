{
  pkgs,
  lib,
  config,
  ...
}: let
  switch-or-activate = pkgs.writeShellScriptBin "switch-or-activate" ''
    window_name=
    if [ -z "$1" ]; then
      echo "First argument must be window name"
      exit 1
    fi
    window_name="$1"

    binary_path=
    if [ -z "$2" ]; then
      echo "Second argument must be binary path"
      exit 1
    fi
    binary_path="$2"

    use_class=0
    if [ "$3" = "--class" ]; then
      use_class=1
    fi

    # Try to switch to the window
    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
      case "$(echo "$XDG_CURRENT_DESKTOP" | ${pkgs.coreutils}/bin/tr '[:upper:]' '[:lower:]')" in
        *gnome*)
          output=
          if [ $use_class = 1 ]; then
            output=$(busctl --user call org.gnome.Shell /de/lucaswerkmeister/ActivateWindowByTitle de.lucaswerkmeister.ActivateWindowByTitle activateByWmClass s "$window_name")
          else
            output="$(busctl --user call org.gnome.Shell /de/lucaswerkmeister/ActivateWindowByTitle de.lucaswerkmeister.ActivateWindowByTitle activateBySubstring s "$window_name")"
          fi

          # If we couldn't switch, then start a new instance
          if (echo "$output" | ${pkgs.gnugrep}/bin/grep false); then
            eval "$binary_path" &> /dev/null & disown
          fi
        ;;

        *)
          echo "Unsupported desktop environment"
          exit 1
        ;;
      esac
    else # X11
      if [ $use_class = 1 ]; then
        ${pkgs.wmctrl}/bin/wmctrl -a "$window_name" -x
      else
        ${pkgs.wmctrl}/bin/wmctrl -a "$window_name"
      fi

      # If we couldn't switch, then start a new instance
      if [ $? -gt 0 ]; then
        eval "$binary_path" &> /dev/null & disown
      fi
    fi
  '';

  soa-bin = "${switch-or-activate}/bin/switch-or-activate";

  conditional-keymaps = [
    {
      condition = config.setup.firefox.enable;
      keymap = {
        name = "Firefox";
        remap.alt-f.launch = [soa-bin "Firefox" "${config.programs.firefox.package.outPath}/bin/firefox"];
      };
    }
    {
      condition = config.setup.desktopEnvironments.gnome.enable;
      keymap = {
        name = "Terminator";
        remap.alt-y.launch = [soa-bin "terminator" "${pkgs.terminator}/bin/terminator" "--class"];
      };
    }
  ];

  xremap-config = {
    keymap = lib.lists.flatten (builtins.map ({
      condition,
      keymap,
    }:
      if condition
      then [keymap]
      else [])
    conditional-keymaps);
  };
in {
  # TODO: Fork xremap/nix-flake to add `enable` option
  # Current xremap is always installed but we just remove all the mappings when
  # it's disabled
  services.xremap = {
    withGnome = true;
    config =
      if config.setup.miscPrograms.xremap
      then xremap-config
      else {};
  };
}
