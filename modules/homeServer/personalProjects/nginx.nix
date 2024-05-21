{
  pkgs,
  lib,
  config,
  inputs,
  system,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgPp = cfg.personalProjects;

  tictactoe-nginx = let
    tictactoe-web = inputs.tic-tac-toe.packages.${system}.web.overrideAttrs {
      TRUNK_BUILD_PUBLIC_URL = "/tictactoe/";
    };
    tictactoe-doc = inputs.tic-tac-toe.packages.${system}.doc;
  in
    pkgs.stdenvNoCC.mkDerivation {
      name = "tictactoe-nginx";
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/tictactoe/docs
        cp -rv ${tictactoe-web}/* $out/tictactoe/
        cp -rv ${tictactoe-doc}/share/doc/* $out/tictactoe/docs/
      '';
    };

  wordle-nginx = let
    wordle-web = inputs.wordle.packages.${system}.web.overrideAttrs {
      TRUNK_BUILD_PUBLIC_URL = "/wordle/";
    };
    wordle-doc = inputs.wordle.packages.${system}.doc;
  in
    pkgs.stdenvNoCC.mkDerivation {
      name = "wordle-nginx";
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/wordle/docs
        cp -rv ${wordle-web}/* $out/wordle/
        cp -rv ${wordle-doc}/share/doc/* $out/wordle/docs/
      '';
    };

  optLoc = condition: location:
    if condition
    then location
    else {};
in {
  config = lib.mkIf cfgPp.enable {
    services.nginx = {
      virtualHosts."${cfg.domainName}" = {
        locations =
          optLoc cfgPp.tictactoe {
            "/tictactoe".root = "${tictactoe-nginx}";
          }
          // optLoc cfgPp.wordle {
            "/wordle".root = "${wordle-nginx}";
          };
      };
    };
  };
}
