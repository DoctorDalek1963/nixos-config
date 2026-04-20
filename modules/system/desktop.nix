{
  flake.aspects =
    { aspects, ... }:
    {
      system-desktop = {
        includes = [ aspects.system-core ];

        nixos = { };

        homeManager =
          { config, ... }:
          {
            xdg = {
              enable = true;

              userDirs =
                let
                  home = "${config.home.homeDirectory}";
                in
                {
                  enable = true; # TODO: Only when graphical?
                  createDirectories = true;
                  setSessionVariables = true;

                  documents = "${home}/Documents";
                  download = "${home}/Downloads";
                  music = "${home}/Music";
                  pictures = "${home}/Pictures";
                  videos = "${home}/Videos";

                  desktop = null;
                  publicShare = null;
                  templates = null;
                };
            };
          };
      };
    };
}
