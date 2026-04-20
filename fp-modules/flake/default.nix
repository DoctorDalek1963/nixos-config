{
  flake-file = {
    description = "DoctorDalek's NixOS flake";

    inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      # nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable"; # Useful when the system uses a stable branch

      nur = {
        url = "github:nix-community/nur";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };
  };
}
