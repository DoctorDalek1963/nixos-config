{
  lib,
  config,
  osConfig,
  ...
}: {
  config = lib.mkIf osConfig.setup.androidTools.enable {
    setup = {
      programming.jetbrains = true;

      impermanence.keepDirs = [
        # For ADB
        ".android"

        # For Android Studio app development
        ".config/.android"
        ".config/Google"
        ".local/share/Google"
        ".gradle"
      ];
    };

    home.sessionVariables.ANDROID_AVD_HOME = "${config.home.homeDirectory}/.config/.android/avd";
  };
}
