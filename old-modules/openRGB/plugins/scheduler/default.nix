# This code was taken mostly from
# https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/by-name/op/openrgb-plugin-effects/package.nix
# and https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/by-name/op/openrgb-plugin-hardwaresync/package.nix
# This file MUST be called with `pkgs.libsForQt5.callPackage` to supply the correct arguments
{
  lib,
  stdenv,
  fetchFromGitLab,
  qtbase,
  openrgb,
  glib,
  qmake,
  pkg-config,
  wrapQtAppsHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "openrgb-plugin-scheduler";
  version = "0.9";

  src = fetchFromGitLab {
    owner = "OpenRGBDevelopers";
    repo = "OpenRGBSchedulerPlugin";
    rev = "release_${finalAttrs.version}";
    hash = "sha256-IYKwVjfrDnHhLS402Dp1t8gQZ/wDBUWdNS+dG+Tvkuk=";
    fetchSubmodules = true;
  };

  patches = [ ./install-libs.patch ];

  postPatch = ''
    # Use the source of openrgb from nixpkgs instead of the submodule
    rm -r OpenRGB
    ln -s ${openrgb.src} OpenRGB
  '';

  buildInputs = [
    qtbase
    glib
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
})
