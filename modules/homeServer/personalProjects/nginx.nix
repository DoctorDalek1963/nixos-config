{
  lib,
  config,
  inputs,
  system,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgPp = cfg.personalProjects;

  tictactoe-web = inputs.tic-tac-toe.packages.${system}.web.overrideAttrs {
    TRUNK_BUILD_PUBLIC_URL = "/tictactoe/";
  };
  tictactoe-doc = inputs.tic-tac-toe.packages.${system}.doc-web;

  wordle-web = inputs.wordle.packages.${system}.web.overrideAttrs {
    TRUNK_BUILD_PUBLIC_URL = "/wordle/";
  };
  wordle-doc = inputs.wordle.packages.${system}.doc;

  optSet = condition: set:
    if condition
    then set
    else {};
in {
  config = lib.mkIf (cfg.enable && cfgPp.enable) {
    services.nginx.virtualHosts."${cfg.domainName}" = {
      locations =
        optSet cfgPp.tictactoe {
          "/tictactoe/" = {
            alias = "${tictactoe-web}/";
            index = "index.html";
          };
          "/tictactoe/docs/".alias = "${tictactoe-doc}/share/doc/";

          "/tictactoe".return = "301 /tictactoe/";
          "/tictactoe/docs".return = "301 /tictactoe/docs/tictactoe/index.html";
        }
        // optSet cfgPp.wordle {
          "/wordle/" = {
            alias = "${wordle-web}/";
            index = "index.html";
          };
          "/wordle/docs/".alias = "${wordle-doc}/share/doc/";

          "/wordle".return = "301 /wordle/";
          "/wordle/docs".return = "301 /wordle/docs/wordle/index.html";
        };
    };
  };
}
