{
  config,
  ...
}:
{
  home-manager = {
    sharedModules = [ ../home-manager/setup.nix ];

    users = (import ../home-manager/defs.nix)."${config.setup.hostname}";
  };
}
