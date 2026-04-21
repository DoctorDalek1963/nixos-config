{
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "current-age";
  version = "0.1.0";

  src = ./.;

  cargoHash = "sha256-pGTSsp0xuw5DvvIfnSTGp7OYvE/4OkrCh90u21+6y34=";

  meta = {
    description = "Print current age, given date of birth";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.DoctorDalek1963 ];
    mainProgram = "current-age";
  };
}
