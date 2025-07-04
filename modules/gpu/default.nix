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

    systemd = {
      packages = [pkgs.lact];
      services.lactd.wantedBy = ["multi-user.target"];
    };
  };
}
