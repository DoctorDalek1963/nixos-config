{
  pkgs,
  lib,
  config,
  inputs,
  system,
  ...
}:
with lib; {
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

    nvim = mkOption {
      type = types.submodule {
        options = {
          pkg = mkOption {type = types.package;};
          path = mkOption {type = types.str;};
        };
      };
      default =
        if config.setup.terminalTools.nvimCustom
        then rec {
          pkg = inputs.nixvim-flake.packages.${system}.default;
          path = "${pkg}/bin/nvim";
        }
        else rec {
          pkg = pkgs.nvim;
          path = "${pkg}/bin/nvim";
        };
    };
  };
}
