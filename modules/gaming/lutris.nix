{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.gaming;

  lutris = pkgs.lutris.override {
    extraPkgs =
      p: with p; [
        winetricks
      ];

    extraLibraries = _p: [ ];
  };
in
{
  config = lib.mkIf (cfg.enable && cfg.lutris) {
    environment.systemPackages = [ lutris ];

    # TODO: Remove this once Lutris is fixed
    nixpkgs.overlays = [
      # Skipping tests while upstream sorts it out, revert once
      # Hydra consistently builds openldap green.
      (_final: prev: {
        openldap = prev.openldap.overrideAttrs {
          doCheck = !prev.stdenv.hostPlatform.isi686;
        };
      })
    ];
  };
}
