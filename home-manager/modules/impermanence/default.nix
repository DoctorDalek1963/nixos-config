{
  lib,
  config,
  inputs,
  osConfig,
  ...
}: let
  cfg = config.setup.impermanence;
in {
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
    ./extras.nix
  ];

  config = lib.mkIf cfg.enable {
    home.persistence."/persist${config.home.homeDirectory}" = {
      # See /modules/impermanence/default.nix
      allowOther = !osConfig.programs.fuse.userAllowOther;

      directories = cfg.keepDirs;
      files = cfg.keepFiles;
    };
  };
}
