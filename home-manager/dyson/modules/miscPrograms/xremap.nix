{
  pkgs,
  config,
  ...
}: let
  switch-or-activate = pkgs.writeScriptBin "switch-or-activate" ''
    #!/usr/bin/env bash

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

    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
      echo "TODO: Implement switch-or-activate for Wayland"
    else # X11
      if [ $use_class = 1 ]; then
        wmctrl -a "$window_name" -x
      else
        wmctrl -a "$window_name"
      fi

      if [ $? -gt 0 ]; then
        eval "$binary_path" &> /dev/null & disown
      fi
    fi
  '';

  soa-bin = "${switch-or-activate}/bin/switch-or-activate";

  # TODO: Make a derivation for a shell script that can switch to an active
  # window if it exists or start a new instance of that program. Then use that
  # shell script for the xremap maps
  conditional-keymaps = [
    {
      condition = config.setup.firefox.enable;
      keymap = {
        name = "Firefox";
        remap.alt-f.launch = [soa-bin "firefox" "${config.programs.firefox.package.outPath}/bin/firefox"];
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
