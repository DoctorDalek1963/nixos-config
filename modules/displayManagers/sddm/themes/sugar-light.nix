{
  stdenv,
  fetchFromGitHub,
}: {background ? null}:
stdenv.mkDerivation {
  name = "sddm-sugar-light";

  src = fetchFromGitHub {
    owner = "MarianArlt";
    repo = "sddm-sugar-light";
    rev = "19bac00e7bd99e0388d289bdde41bf6644b88772";
    hash = "sha256-KddZtCTionZntQPD8ttXhHFLZl8b1NsawG9qbjuI1fc=";
  };

  installPhase =
    ''
      mkdir -p $out
      cp -Rv ./* $out/
    ''
    + (
      if background != null
      then ''
        cp -v ${background} $out/Background.jpg
      ''
      else ""
    );
}
