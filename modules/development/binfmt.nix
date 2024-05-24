{config, ...}: let
  cfg = config.setup.binfmt;

  optItemList = cond: item:
    if cond
    then [item]
    else [];
in {
  boot.binfmt.emulatedSystems = optItemList cfg.aarch64 "aarch64-linux";
}
