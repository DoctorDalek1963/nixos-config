{
  flake.modules.generic.nix-conf = {
    nix = {
      settings = {
        # Keep the nix store optimised
        auto-optimise-store = true;

        # Default is 64 * 1024 * 1024
        download-buffer-size = 256 * 1024 * 1024;

        # Enable flakes
        experimental-features = [
          "nix-command"
          "flakes"
        ];

        trusted-users = [
          "root"
          "@wheel"
        ];

        connect-timeout = 5;
      };

      # Garbage collect old packages every week
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };

      # Use unstable packages on the command line with `nix shell unstable#pkgName`
      # registry.unstable = {
      #   from = {
      #     type = "indirect";
      #     id = "unstable";
      #   };
      #   flake = inputs.nixpkgs-unstable;
      #   exact = true;
      # };
    };
  };
}
