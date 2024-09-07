{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;

  stringList = strings:
    mkOption {
      type = types.listOf types.str;
      default = strings;
    };
in {
  # Here we can define constant values that can be referenced from any other files
  options.consts = {
    valid-gnome-themes = stringList ["catppuccin-adaptive-macchiato-mauve" "vimix-amethyst"];
    valid-terminal-themes = stringList ["catppuccin-macchiato" "onedark"];

    valid-shells = stringList ["bash"];

    # Defined in modules/terminal/tools/nvim.nix
    nvimPkg = mkOption {type = types.package;};

    nvimPath = mkOption {
      type = types.nonEmptyStr;
      default = "${config.consts.nvimPkg}/bin/nvim";
    };
  };
}
