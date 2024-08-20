{
  pkgs,
  lib,
  config,
  ...
}: let
  julia = pkgs.julia.withPackages ["Pluto"];
in {
  config = lib.mkIf config.setup.programming.julia {
    home.packages = [julia];

    setup = {
      impermanence = {
        keepFiles = [".julia/logs/repl_history.jl"];
        keepDirs = [".julia/pluto_notebooks"];
      };

      terminal.shellAliases = {
        jl = "julia";
        pnb = "${julia}/bin/julia -e 'import Pluto; Pluto.run()'";
      };
    };
  };
}
