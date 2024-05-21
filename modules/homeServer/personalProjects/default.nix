{
  pkgs,
  lib,
  config,
  inputs,
  system,
  ...
}: let
  cfg = config.setup.homeServer.personalProjects;

  wordle-nginx = let
    wordle-web = inputs.wordle.packages.${system}.web.overrideAttrs {TRUNK_BUILD_PUBLIC_URL = "/wordle/";};
    wordle-doc = inputs.wordle.packages.${system}.doc;
  in
    pkgs.stdenv.mkDerivation {
      name = "wordle-nginx";
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/wordle/docs
        cp -rv ${wordle-web}/* $out/wordle/
        cp -rv ${wordle-doc}/share/doc/* $out/wordle/docs/
      '';
    };
in {
  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts."bert-nixos.triceratops-egret.ts.net" = {
        locations = {
          "/wordle".root = "${wordle-nginx}";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [80 443];
  };
}
