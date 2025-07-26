{
  pkgs,
  lib,
  config,
  ...
}:
let
  custom-nh = pkgs.nh.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [ ./nh_clean_show_output.patch ];
  });
in
{
  config = lib.mkIf config.setup.programming.nix {
    home.packages = with pkgs; [
      custom-nh
      nix-output-monitor
      nix-tree
    ];

    setup.terminal.shellAliases = {
      n = "nix";
      nhos = "NH_FLAKE=/etc/nixos ${custom-nh}/bin/nh os";
      nhcl = "${custom-nh}/bin/nh clean all --keep 3 --nogcroots";
      nrpl = "nix repl --file '<nixpkgs>'";
    };
  };
}
