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

  buildInputs = [ external-program ];

  buildPhase = ''
    substituteInPlace BarWidget.qml \
      --replace-fail "@EXTERNAL_PROGRAM@" "${lib.getExe external-program}" \
  '';

  installPhase = ''
    mkdir -p $out
    cp -rv *.qml manifest.json $out/
  '';

  meta = {
    description = "Noctalia plugin to display current age";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.DoctorDalek1963 ];
  };
}
