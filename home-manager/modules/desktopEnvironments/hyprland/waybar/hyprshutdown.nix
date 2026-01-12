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
stdenv.mkDerivation {
  pname = "hyprshutdown";
  version = "git-0c9cec7";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprshutdown";
    rev = "0c9cec7809a715c5c9a99a585db0b596bfb96a59";
    hash = "sha256-JMpLic41Jw6kDXXMtj6tEYUMu3QQ0Sg/M8EBxmAwapU=";
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
