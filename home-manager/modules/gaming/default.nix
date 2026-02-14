{
  lib,
  osConfig,
  ...
}:
let
  cfgGaming = osConfig.setup.gaming;

  extraMangoHudConf =
    {
      "Alex-NixOS" = {
        gpu_text = "Radeon,Mendocino";
      };
    }
    ."${osConfig.setup.hostname}" or { };
in
{
  config = lib.mkIf cfgGaming.enable {
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
      }
      // extraMangoHudConf;
    };

    setup.impermanence.keepDirs = [
      "Games"
      ".config/ludusavi"
    ]
    ++ lib.optionals cfgGaming.steam.enable [
      ".local/share/Steam"
      ".local/share/doublefine"
      ".local/share/FasterThanLight"
      ".local/share/Euro Truck Simulator 2"
      ".factorio"
    ]
    ++ lib.optionals cfgGaming.lutris [
      ".local/share/lutris"
      ".local/share/net.lutris.Lutris"
      ".cache/net.lutris.Lutris"
      ".cache/winetricks"
    ]
    ++ lib.optionals cfgGaming.minecraft [
      ".local/share/PrismLauncher"
    ]
    ++ lib.optionals cfgGaming.emulators.ps3 [
      ".config/rpcs3"
      ".cache/rpcs3"
    ];
  };
}
