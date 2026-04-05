{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
{
  config = lib.mkIf config.setup.programming.nix {
    home.packages = with pkgs; [
      nix-output-monitor
      nix-tree
      nixpkgs-reviewFull
      nh
    ];

    setup.terminal.shellAliases =
      let
        cores =
          {
            "Alex-NixOS" = 6;
            "Bert-NixOS" = 1;
          }
          .${osConfig.setup.hostname} or 3;

        nhos = "NH_FLAKE=/etc/nixos nh os";
      in
      {
        n = "nix";
        inherit nhos;
        nhcl = "nh clean all --keep 3 --nogcroots";
        nrpl = "nix repl --file '<nixpkgs>'";

        nhos-boot = "${nhos} boot --ask -- --max-jobs ${toString cores} --keep-going --show-trace";
        nhos-switch = "${nhos} switch --ask -- --max-jobs ${toString cores} --keep-going --show-trace";
      };
  };
}
