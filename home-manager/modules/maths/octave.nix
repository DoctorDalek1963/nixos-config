{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.maths;
in
{
  config = lib.mkIf cfg.enable {
    home = {
      packages = [
        (pkgs.octaveFull.withPackages (p: [
          p.symbolic
        ]))
      ];

      file.".octaverc".text = ''
        pkg load symbolic

        syms a b c d i j k l m n p q r t u v w x y z
      '';
    };

    setup.impermanence.keepFiles = [ ".local/share/octave/history" ];
  };
}
