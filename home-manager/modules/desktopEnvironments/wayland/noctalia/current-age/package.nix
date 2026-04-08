{
  lib,
  callPackage,
  stdenvNoCC,
}:
let
  external-program = callPackage ./external-program/package.nix { };
in
stdenvNoCC.mkDerivation {
  name = "noctalia-current-age";

  src = ./.;
  dontUnpack = true;

  buildPhase = ''
    # TODO: substitute in place with ${lib.getExe external-program}
  '';

  installPhase = ''
    # TODO
  '';

  meta = {
    description = "Noctalia plugin to display current age";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.DoctorDalek1963 ];
  };
}
