{
  flake.aspects.gaming = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.prismlauncher
        ];

        impermanence.directories = [
          ".local/share/PrismLauncher"
        ];
      };
  };
}
