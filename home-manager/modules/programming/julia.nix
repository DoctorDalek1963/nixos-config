{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.programming.julia {
    home = {
      packages = with pkgs; [julia];
      file.".julia/config/startup.jl".text =
        # julia
        ''
          using Statistics
          using LinearAlgebra
        '';
    };
  };
}
