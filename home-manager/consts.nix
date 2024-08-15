{
  pkgs,
  lib,
  config,
  inputs,
  system,
  ...
}: let
  inherit (lib) mkOption types;

  stringList = strings:
    mkOption {
      type = types.listOf types.str;
      default = strings;
    };

  nvim-pkg =
    {
      basic = pkgs.neovim;
      small = inputs.nixvim-flake.packages.${system}.nvim-small;
      medium = inputs.nixvim-flake.packages.${system}.nvim-medium;
      full = inputs.nixvim-flake.packages.${system}.nvim-full;
    }
    .${config.setup.terminal.tools.nvim};
in {
  # Here we can define constant values that can be referenced from any other files
  options.consts = {
    lib = {
      optItemList = mkOption {
        default = opt: item:
          if opt
          then [item]
          else [];
      };
    };

    valid-gnome-themes = stringList ["catppuccin-adaptive-macchiato-mauve" "vimix-amethyst"];
    valid-terminal-themes = stringList ["catppuccin-macchiato" "onedark"];

    valid-shells = stringList ["bash"];

    nvimPkg = mkOption {
      type = types.package;
      default = nvim-pkg;
    };

    nvimPath = mkOption {
      type = types.nonEmptyStr;
      default = "${nvim-pkg}/bin/nvim";
    };
  };
}
