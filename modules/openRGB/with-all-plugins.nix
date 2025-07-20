{pkgs}: let
  plugin-scheduler = pkgs.libsForQt5.callPackage ./plugins/scheduler {};
in
  pkgs.openrgb.withPlugins [
    pkgs.openrgb-plugin-effects
    pkgs.openrgb-plugin-hardwaresync
    plugin-scheduler
  ]
