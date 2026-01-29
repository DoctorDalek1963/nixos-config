# Taken from https://github.com/hyprwm/hyprpwcenter/blob/main/nix/default.nix
{
  fetchFromGitHub,
  lib,
  stdenv,
  cmake,
  pkg-config,
  aquamarine,
  cairo,
  glaze,
  hyprgraphics,
  hyprtoolkit,
  hyprutils,
  libdrm,
  pixman,
}:
let
  version = "0.1.0";
in
stdenv.mkDerivation {
  pname = "hyprshutdown";
  inherit version;

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprshutdown";
    rev = "v${version}";
    hash = "sha256-dp5lyZzKsjdqJLfwr0S4ILets8eu1kLfBB2y/LxspsU=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    aquamarine
    cairo
    (glaze.override { enableSSL = false; })
    hyprgraphics
    hyprtoolkit
    hyprutils
    libdrm
    pixman
  ];

  meta = {
    homepage = "https://github.com/hyprwm/hyprshutdown";
    description = "A graceful shutdown utility for Hyprland";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    mainProgram = "hyprshutdown";
  };
}
