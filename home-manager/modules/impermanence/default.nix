{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.setup.impermanence;
in {
  imports = [inputs.impermanence.nixosModules.home-manager.impermanence];

  config = lib.mkIf cfg.enable {
    home.persistence."/persist/${config.home.homeDirectory}" = {
      enable = true;
      allowOther = true;

      directories = cfg.keepDirs;
      files = cfg.keepFiles;
    };
  };
}
