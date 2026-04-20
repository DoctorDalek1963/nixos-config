{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ ./extra-firmware-config.nix ];

  # Most of this config was taken from
  # https://github.com/mcdonc/nixos-pi-zero-2/blob/385daa4529528901a318129c3517f845dce49240/common.nix

  nixpkgs = {
    # Uncomment this to do full cross-compilation. The alternative that I'm
    # currently using is to emulate being on an aarch64 system with
    # boot.binfmt.emulatedSystems, since this allows nix to find packages in
    # the cache as well.
    # buildPlatform.system = "x86_64-linux";

    hostPlatform.system = "aarch64-linux";

    # https://github.com/NixOS/nixpkgs/issues/154163#issuecomment-1350599022
    overlays = [
      (_final: super: {
        makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];
  };

  nix.settings.max-jobs = 2;

  users.groups.gpio.members = [ "pi" ];

  hardware = {
    # Keep this to make sure wifi works
    enableRedistributableFirmware = lib.mkForce false;
    firmware = [ pkgs.raspberrypiWirelessFirmware ];

    raspberry-pi."4" = {
      apply-overlays-dtmerge.enable = true;

      gpio.enable = true;

      leds = {
        act.disable = true;
        eth.disable = true;
        pwr.disable = true;
      };

      fkms-3d.enable = config.setup.isGraphical;
    };

    deviceTree = {
      enable = true;

      # Force generic filter to avoid conflicts between modesetting and
      # LEDs in nixos-hardware
      filter = lib.mkForce "*-rpi-4*.dtb";
    };
  };

  boot = {
    # Avoids warning: mdadm: Neither MAILADDR nor PROGRAM has been set.
    # This will cause the `mdmon` service to crash.
    # See: https://github.com/NixOS/nixpkgs/issues/254807
    swraid.enable = lib.mkForce false;
  };

  services = {
    # dnsmasq.enable = true;
    getty.autologinUser = "pi";

    zram-generator = {
      enable = true;
      settings.zram0 = {
        compression-algorithm = "zstd";
        zram-size = "ram * 2";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    bintools
    bluez
    dig
    ethtool
    libraspberrypi
    minicom
    (python3.withPackages (
      p: with p; [
        gpiozero
        pyserial
        rpi-gpio
      ]
    ))
    raspberrypi-eeprom
    usbutils
  ];

  image = {
    baseName = "pi";
    fileName = "pi.img";
  };

  sdImage = {
    compressImage = false;

    extraFirmwareConfig = {
      # Give up VRAM for more Free System Memory
      # - Disable camera which automatically reserves 128MB VRAM
      start_x = 0;

      # Reduce allocation of VRAM to 16MB minimum for non-rotated
      # (32MB for rotated)
      gpu_mem = 16;

      # Configure display to 800x600 so it fits on most screens
      # * See: https://elinux.org/RPi_Configuration
      hdmi_group = 2;
      hdmi_mode = 8;
    };
  };
}
