{
  perSystem =
    { pkgs, ... }:
    {
      packages.lutris = pkgs.lutris.override {
        extraPkgs = p: with p; [ winetricks ];

        extraLibraries = _p: [ ];
      };
    };

  flake.aspects.gaming = {
    nixos =
      { self', ... }:
      {
        environment.systemPackages = [
          self'.packages.lutris
        ];
      };

    homeManager = {
      impermanence.directories = [
        ".local/share/lutris"
        ".local/share/net.lutris.Lutris"
        ".cache/net.lutris.Lutris"
        ".cache/winetricks"
      ];
    };
  };
}
