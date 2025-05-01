{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.hasBluetooth {
    hardware.bluetooth.enable = true;
    setup.impermanence.keepDirs = ["/var/lib/bluetooth"];
  };
}
