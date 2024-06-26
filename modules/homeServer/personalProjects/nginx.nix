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

  optSet = condition: set:
    if condition
    then set
    else {};

  optList = condition: list:
    if condition
    then list
    else [];
in {
  config = lib.mkIf (cfg.enable && cfgPp.enable) {
    services.nginx.virtualHosts."${cfg.domainName}" = {
      locations =
        optSet cfgPp.tictactoe {
          "/tictactoe".root = "${tictactoe-nginx}";
        }
        // optSet cfgPp.wordle {
          "/wordle".root = "${wordle-nginx}";
        };
      extraConfig = lib.concatStringsSep "\n" (
        optList cfgPp.tictactoe [
          "rewrite ^/tictactoe/docs(/(index.html)?)?$ /tictactoe/docs/tictactoe permanent;"
        ]
        ++ optList cfgPp.wordle [
          "rewrite ^/wordle/docs(/(index.html)?)?$ /wordle/docs/wordle permanent;"
        ]
      );
    };
  };
}
