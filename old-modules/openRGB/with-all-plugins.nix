{ pkgs }:
pkgs.openrgb.withPlugins [
  pkgs.openrgb-plugin-effects
  pkgs.openrgb-plugin-hardwaresync
  # (pkgs.libsForQt5.callPackage ./plugins/scheduler { }) # TODO: Is this broken or am I stupid?
]
