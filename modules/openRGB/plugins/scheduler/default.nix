# This code was taken mostly from
# https://github.com/NixOS/nixpkgs/blob/nixos-23.11/pkgs/applications/misc/openrgb-plugins/effects/default.nix
# and https://github.com/NixOS/nixpkgs/blob/nixos-23.11/pkgs/applications/misc/openrgb-plugins/hardwaresync/default.nix
# This file MUST be called with `pkgs.libsForQt5.callPackage` to supply the correct arguments
{
  lib,
  stdenv,
  fetchFromGitLab,
  qtbase,
  openrgb,
  glib,
  libgtop,
  lm_sensors,
  qmake,
  pkg-config,
  wrapQtAppsHook,
}:
stdenv.mkDerivation rec {
  pname = "openrgb-plugin-scheduler";
  version = "0.9-dev";

  src = fetchFromGitLab {
    owner = "OpenRGBDevelopers";
    repo = "OpenRGBSchedulerPlugin";
    rev = "b7cc3a9dd52033052e1dc41e1d43a8ab12880288";
    hash = "sha256-IM1kI4Adx/WGlDroTWvrQW6Xij+l4tg3k7/R9WI9s94=";
    fetchSubmodules = true;
  };

  patches = [./install-libs.patch];

  postPatch = ''
    # Use the source of openrgb from nixpkgs instead of the submodule
    rm -r OpenRGB
    ln -s ${openrgb.src} OpenRGB
  '';

  buildInputs = [
    qtbase
    glib
    libgtop
    lm_sensors
  ];

  nativeBuildInputs = [
    qmake
    pkg-config
    wrapQtAppsHook
  ];

  meta = with lib; {
    homepage = "https://gitlab.com/OpenRGBDevelopers/OpenRGBSchedulerPlugin";
    description = "Schedule basic actions (change profile, turn off leds) with OpenRGB";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
