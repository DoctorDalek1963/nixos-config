{
  flake.aspects.gaming = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.rpcs3
        ];
      };

    homeManager = {
      impermanence.directories = [
        ".config/rpcs3"
        ".cache/rpcs3"
      ];
    };
  };
}
