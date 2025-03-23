{
  lib,
  osConfig,
  ...
}: {
  config = lib.mkIf osConfig.setup.androidTools.enable {
    setup.impermanence.keepDirs = [
      # For ADB
      ".android"

      # For Android Studio app development
      ".config/.android"
      ".config/Google"
      ".local/share/Google"
      ".gradle"
    ];
  };
}
