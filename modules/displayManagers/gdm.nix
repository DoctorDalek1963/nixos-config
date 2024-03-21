{config, ...}: {
  services.xserver.displayManager.gdm.enable = config.setup.displayManagers.gdm.enable;
}
