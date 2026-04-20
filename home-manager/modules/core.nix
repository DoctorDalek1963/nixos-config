{
  lib,
  osConfig,
  ...
}:
{
  # Stuff tends to collect in my Downloads, so I'm intentionally not persisting it
  setup.impermanence.keepDirs = lib.mkIf osConfig.setup.isGraphical [
    "Documents"
    "Music"
    "Pictures"
    "Videos"
  ];
}
