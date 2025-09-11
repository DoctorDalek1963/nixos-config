{
  pkgs,
  lib,
  config,
  system,
  inputs,
  ...
}:
let
  nvim-extend = pkgs.writeShellApplication {
    name = "nvim-extend";
    runtimeInputs = [
      pkgs.mktemp
      pkgs.nix
    ];
    text = ''
      if [ $# -lt 1 ]; then
        echo "Usage: nvim-extend '<config options>'"
        echo
        echo "Examples:   (note the ; at the end)"
        echo "  nvim-extend 'setup.lang.c_cpp = true;'"
        echo "  nvim-extend 'setup.lang = {dockerfile = true; webDev = true;};'"
        echo "  alias jv=\$(nvim-extend 'setup.lang.jvm = true;')"
        exit 1
      fi

      tmpdir=$(mktemp -d)
      cat > "$tmpdir/flake.nix" << EOF
      {
        outputs = {nixvim-config, ...}: let
          pkgs = nixvim-config.inputs.nixpkgs.legacyPackages.${system};
          inherit (pkgs) lib;
        in {
          packages.${system}.default =
            nixvim-config.packages.${system}.nvim-medium.extend
            {$1};
        };
      }
      EOF

      set +e
      store_path="$(nix build "$tmpdir" --quiet --no-link --print-out-paths --inputs-from /etc/nixos 2> /dev/null)"
      set -e

      rm -rf "$tmpdir"

      if [ -n "$store_path" ]; then
        echo "$store_path/bin/nvim"
      else
        echo "ERROR: nixvim extension failed to build"
        exit 1
      fi
    '';
  };
in
{
  options.setup.shared.nvim = {
    package = lib.mkOption {
      description = "The package for Neovim";
      type = lib.types.package;
    };

    path = lib.mkOption {
      description = "The path to the executable of the Neovim package";
      type = lib.types.nonEmptyStr;
      default = lib.getExe config.setup.shared.nvim.package;
      readOnly = true;
    };
  };

  config = {
    setup = {
      shared.nvim.package =
        {
          stock = pkgs.neovim;
          tiny = inputs.nixvim-config.packages.${system}.nvim-tiny;
          small = inputs.nixvim-config.packages.${system}.nvim-small;
          medium = inputs.nixvim-config.packages.${system}.nvim-medium;
          full = inputs.nixvim-config.packages.${system}.nvim-full;
        }
        .${config.setup.terminal.tools.nvim};

      terminal.shellAliases = {
        v = config.setup.shared.nvim.path;

        nvim-dev = "nix run ${config.home.homeDirectory}/repos/nixvim-config --";

        nvim-tiny = "nix run github:DoctorDalek1963/nixvim-config#nvim-tiny";
        nvim-small = "nix run github:DoctorDalek1963/nixvim-config#nvim-small";
        nvim-medium = "nix run github:DoctorDalek1963/nixvim-config#nvim-medium";
        nvim-full = "nix run github:DoctorDalek1963/nixvim-config#nvim-full";
      };
    };

    home = {
      packages = [
        config.setup.shared.nvim.package
        nvim-extend
      ];

      sessionVariables = {
        EDITOR = config.setup.shared.nvim.path;
        MANPAGER = "${config.setup.shared.nvim.path} +Man!";
      };

    };
  };
}
