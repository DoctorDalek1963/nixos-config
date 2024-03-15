# This derivation was adapted from
# https://github.com/NixOS/nixpkgs/blob/cec1751cbdf9ffc749fee0d198a189ca69f196da/pkgs/desktops/gnome/extensions/buildGnomeExtension.nix
{
  pkgs,
  lib,
  ...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-thanatophobia";
  version = "12";

  # This is my fork, built to work with GNOME 45
  src = pkgs.fetchFromGitHub {
    owner = "DoctorDalek1963";
    repo = "thanatophobia";
    rev = "52d91b15e05a0fc134521b9311f2b474e72e907f";
    hash = "sha256-7cLml1KLthUSMe1hnSsOLbDS+ud6UqkkmqMQDZ6bBiM=";
  };

  nativeBuildInputs = [pkgs.buildPackages.glib];

  buildPhase = ''
    runHook preBuild
    if [ -d schemas ]; then
      glib-compile-schemas --strict schemas
    fi
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gnome-shell/extensions/
    cp -r -T . $out/share/gnome-shell/extensions/thanatophobia@yatx.one
    runHook postInstall
  '';

  meta = {
    description = "Displays your age in real time.";
    longDescription = "Displays your age in real time.\n\nGreat source of motivation according to terror management theory!";
    homepage = "https://extensions.gnome.org/extension/4425/thanatophobia/";
    license = lib.licenses.gpl2Plus;
  };
}
