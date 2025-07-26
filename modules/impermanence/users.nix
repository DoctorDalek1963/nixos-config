{
  lib,
  config,
  ...
}:
let
  cfg = config.setup.impermanence;
in
{
  config = lib.mkIf cfg.enable {
    environment.persistence."/persist".users = builtins.listToAttrs (
      map (name: {
        inherit name;
        value = {
          directories = config.home-manager.users."${name}".setup.impermanence.keepDirs;
          files = config.home-manager.users."${name}".setup.impermanence.keepFiles;
        };
      }) (builtins.attrNames config.home-manager.users)
    );
  };
}
