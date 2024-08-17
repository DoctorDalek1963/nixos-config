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

    setup.terminal.shellAliases = {
      jl = "julia";
      pnb = "${julia}/bin/julia -e 'import Pluto; Pluto.run()'";
    };
  };
}
