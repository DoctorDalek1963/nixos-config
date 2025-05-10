{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.programming.nix {
    home.packages = with pkgs; [
      nh
      nix-output-monitor
      nix-tree
    ];

    setup.terminal.shellAliases = {
      n = "nix";
      nhos = "NH_FLAKE=/etc/nixos ${pkgs.nh}/bin/nh os";
      nhcl = "${pkgs.nh}/bin/nh clean all --keep 3 --nogcroots";
    };
  };
}
