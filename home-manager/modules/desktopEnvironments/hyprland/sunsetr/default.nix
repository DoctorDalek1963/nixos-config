{
  pkgs,
  lib,
  osConfig,
  ...
}: let
  sunsetr = pkgs.rustPlatform.buildRustPackage (finalAttrs: {
    pname = "sunsetr";
    version = "0.6.0";

    src = pkgs.fetchFromGitHub {
      owner = "psi4j";
      repo = "sunsetr";
      rev = "v${finalAttrs.version}";
      hash = "sha256-0o9NoN4Db0+Xd/nJdMtBwywzvpw3MsWe18EGhD7uzBI=";
    };

    cargoLock.lockFile = ./Cargo.lock;

    postPatch = ''
      ln -s ${./Cargo.lock} Cargo.lock
    '';

    meta = {
      mainProgram = "sunsetr";
      description = "Automatic blue light filter for Hyprland, Niri, and everything Wayland";
      homepage = "https://github.com/psi4j/sunsetr";
      license = lib.licenses.mit;
      maintainers = [];
    };
  });
in {
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    wayland.windowManager.hyprland.settings.exec-once = [(lib.getExe sunsetr)];

    xdg.configFile."sunsetr/sunsetr.toml".source =
      (pkgs.writers.writeTOML "sunsetr.toml" {
        backend = "wayland";
        start_hyprsunset = false;
        startup_transition = true;
        startup_transition_duration = 1;
        night_temp = 3500;
        day_temp = 6500;
        night_gamma = 80;
        day_gamma = 100;
        update_interval = 60;
        transition_mode = "geo";

        # London
        latitude = 51.508415;
        longitude = -0.125533;
      }).outPath;
  };
}
