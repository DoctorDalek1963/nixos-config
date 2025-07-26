{
  config,
  inputs,
  system,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit inputs system; };

    sharedModules = [ ../home-manager/setup.nix ];

    users = (import ../home-manager/defs.nix)."${config.setup.hostname}";
  };
}
