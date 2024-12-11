{
  pkgs,
  lib,
  ...
}: {
  imports = [./extra-firmware-config.nix];

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
        makeModulesClosure = x:
          super.makeModulesClosure (x // {allowMissing = true;});
      })
    ];
  };

  # Don't build any docs locally
  documentation.enable = false;

  # Keep this to make sure wifi works
  hardware = {
    enableRedistributableFirmware = lib.mkForce false;
    firmware = [pkgs.raspberrypiWirelessFirmware];
  };

  users.groups.gpio.members = ["pi"];

  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
      timeout = 2;
    };

    kernelPackages = pkgs.linuxPackages_rpi4;

    # Disable strict checking of IO memory accesses. This allows the rpi_ws281x
    # library used by Winter WonderLights to work properly
    kernelParams = ["iomem=relaxed"];

    # Avoids warning: mdadm: Neither MAILADDR nor PROGRAM has been set.
    # This will cause the `mdmon` service to crash.
    # See: https://github.com/NixOS/nixpkgs/issues/254807
    swraid.enable = lib.mkForce false;
  };

  services = {
    # dnsmasq.enable = true;
    getty.autologinUser = "pi";

    # https://raspberrypi.stackexchange.com/questions/40105/access-gpio-pins-without-root-no-access-to-dev-mem-try-running-as-root
    udev.extraRules = ''
      KERNEL=="gpiomem", GROUP="gpio", MODE="0660"
      SUBSYSTEM=="gpio", KERNEL=="gpiochip*", ACTION=="add", PROGRAM="${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/chgrp -R gpio /sys/class/gpio && ${pkgs.coreutils}/bin/chmod -R g=u /sys/class/gpio'"
      SUBSYSTEM=="gpio", ACTION=="add", PROGRAM="${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/chgrp -R gpio /sys%p && ${pkgs.coreutils}/bin/chmod -R g=u /sys%p'"
    '';

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
    (python311.withPackages (p: with p; [gpiozero pyserial rpi-gpio]))
    raspberrypi-eeprom
    usbutils
  ];

  sdImage = {
    compressImage = false;
    imageName = "pi.img";

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

  hardware = {
    raspberry-pi."4" = {
      apply-overlays-dtmerge.enable = true;
      fkms-3d.enable = true; # rudolf
      leds = {
        # act.disable = true;
        eth.disable = true;
        # pwr.disable = true;
      };
    };
    deviceTree = {
      enable = true;
    };
  };
}
