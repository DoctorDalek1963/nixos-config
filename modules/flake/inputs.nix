{
  # TODO: Move all of these to relevant places

  flake-file.inputs = {
    # Hardware and device management
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Personal projects for home server
    tic-tac-toe.url = "github:DoctorDalek1963/tic-tac-toe";
    winter-wonderlights.url = "github:DoctorDalek1963/winter-wonderlights";
    wordle.url = "github:DoctorDalek1963/wordle";

    # Other home server stuff
    copyparty = {
      url = "github:9001/copyparty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    whisper-asr-webservice-flake.url = "github:DoctorDalek1963/whisper-asr-webservice-flake";

    # home-manager stuff
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lintrans.url = "github:DoctorDalek1963/lintrans";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim-config = {
      url = "github:DoctorDalek1963/nixvim-config";
      inputs = {
        nixpkgs.follows = "nixpkgs"; # Only while nixvim-config uses the same nixpkgs branch
        flake-parts.follows = "flake-parts";
      };
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    millennium = {
      url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
