{
  pkgs,
  lib,
  config,
  osConfig,
  inputs,
  ...
}:
let
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
      condition = config.setup.librewolf.enable;
      keymap = {
        name = "LibreWolf";
        remap.alt-c.launch = [
          soa-bin
          "LibreWolf"
          "${config.programs.librewolf.package}/bin/librewolf"
        ];
      };
    }
    {
      condition = config.setup.terminal.defaultEmulator == "terminator";
      keymap = {
        name = "Terminator";
        remap.alt-t.launch = [
          soa-bin
          "terminator"
          "${pkgs.terminator}/bin/terminator"
          "--class"
        ];
      };
    }
    {
      condition = config.setup.terminal.defaultEmulator == "wezterm";
      keymap = {
        name = "WezTerm";
        remap.alt-t.launch = [
          soa-bin
          "org.wezfurlong.wezterm"
          "${config.programs.wezterm.package}/bin/wezterm"
          "--class"
        ];
      };
    }
  ];
in
{
  imports = [ inputs.xremap.homeManagerModules.default ];

  services.xremap = {
    enable = config.setup.misc.programs.xremap;

    withGnome = osConfig.setup.desktopEnvironments.gnome.enable;

    # I don't actually use xremap with Hyprland
    # withHypr = osConfig.setup.desktopEnvironments.hyprland.enable;

    config = {
      keymap = lib.lists.flatten (
        builtins.map (
          {
            condition,
            keymap,
          }:
          if condition then [ keymap ] else [ ]
        ) conditional-keymaps
      );
    };
  };

  # The xremap flake creates this service, so we can just slide our own
  # adjusted config in there. We want `KillMode=process` so that when the
  # xremap service gets restarted (like when we run home-manager switch), the
  # spawned processes don't get killed as well.
  systemd.user.services.xremap.Service.KillMode = "process";
}
