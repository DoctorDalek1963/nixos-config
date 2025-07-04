{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.hardware.graphics.enable {
    hardware.amdgpu.overdrive.enable = true;

    environment.systemPackages = with pkgs; [
      amdgpu_top
      lact
    ];

    # To configure overclocking with LACT on a remote machine like a headless
    # server, refer to https://github.com/ilya-zlobintsev/LACT#remote-management
    systemd = {
      packages = [pkgs.lact];
      services.lactd.wantedBy = ["multi-user.target"];
    };
  };
}
