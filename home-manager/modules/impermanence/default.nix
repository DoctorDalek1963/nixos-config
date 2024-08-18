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
    home.persistence."/persist${config.home.homeDirectory}" = {
      # This requires `programs.fuse.userAllowOther = true;` in the NixOS
      # config, but that breaks initrd. See /modules/impermanence/default.nix
      # allowOther = true;
      allowOther = false;

      directories = cfg.keepDirs;
      files = cfg.keepFiles;
    };
  };
}
