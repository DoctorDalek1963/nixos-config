{
  flake.aspects.gaming = {
    nixos =
      { pkgs, lib, ... }:
      {
        boot = {
          kernelPackages = lib.mkDefault pkgs.linuxPackages_xanmod_stable;
          kernelModules = [ "ntsync" ];
        };

        hardware.xone.enable = true;
        programs.gamemode.enable = true;

        systemd.settings.Manager.DefaultLimitNOFILE = "${toString (2048 * 64)}:${toString (2048 * 256)}";
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          ludusavi
        ];

        impermanence.directories = [
          "Games"
          ".config/ludusavi"
        ];

        programs.mangohud = {
          enable = true;

          settings = {
            gpu_stats = true;
            gpu_temp = true;
            gpu_fan = true;

            cpu_stats = true;
            cpu_temp = true;
            core_load = true;
            core_bars = true;

            vram = true;
            ram = true;

            fps = true;
            frametime = true;
            frame_timing = true;

            throttling_status = true;

            present_mode = true;
            gamemode = true;
            resolution = true;

            graphs = "gpu_load,cpu_load";

            # no_display = true;

            text_outline = true;
            round_corners = 10;
            background_alpha = 0.6;
            alpha = 1.0;
          };
        };
      };
  };
}
