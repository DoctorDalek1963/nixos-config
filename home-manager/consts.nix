{ lib, ... }:
let
  stringList =
    strings:
    lib.mkOption {
      type = lib.types.listOf lib.types.nonEmptyStr;
      default = strings;
    };
in
{
  # Here we can define constant values that can be referenced from any other files
  options.consts = {
    valid-gnome-themes = stringList [
      "catppuccin-adaptive-macchiato-mauve"
      "vimix-amethyst"
    ];
    valid-hyprland-themes = stringList [ "catppuccin-macchiato-mauve" ];

    valid-terminal-themes = stringList [
      "catppuccin-macchiato"
      "onedark"
    ];

    valid-shells = stringList [ "bash" ];
  };
}
