{
  config,
  inputs,
  system,
  ...
}: {
  imports = [inputs.home-manager.nixosModules.home-manager];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;

    extraSpecialArgs = {inherit inputs system;};

    sharedModules = [../home-manager/setup.nix];

    users = (import ../home-manager/defs.nix {osConfig = config;})."${config.setup.hostname}";
  };
}
