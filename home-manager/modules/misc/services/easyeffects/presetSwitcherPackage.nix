{
  lib,
  stdenv,
  fetchFromGitLab,
  easyeffects,
  gobject-introspection,
  gtk3,
  libayatana-appindicator,
  python312,
  wrapGAppsHook3,
}:
stdenv.mkDerivation {
  name = "easyeffects-preset-switcher";

  src = fetchFromGitLab {
    owner = "emkay443";
    repo = "easyeffects-systray";
    rev = "1fb2ecf3591e35c8a47a57109beb2a8a4149166f";
    hash = "sha256-o7L8RBFxXQ3IhpaMzZAcqVRylkguOcf7A8QXi/8Hug8=";
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    # TODO (plyer build failure): We can go back to python3 when
    # https://github.com/NixOS/nixpkgs/issues/418869 is fixed
    (python312.withPackages (
      p: with p; [
        pystray
        pillow
        cairosvg
        plyer
        dbus-python
      ]
    ))
    gtk3
    libayatana-appindicator
    easyeffects
  ];

  postPatch = ''
    substituteInPlace easyeffects-systray.py \
      --replace-fail "/usr/share/icons" "${easyeffects}/share/icons"
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 easyeffects-systray.py $out/bin/easyeffects-preset-switcher

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://gitlab.com/emkay443/easyeffects-systray";
    mainProgram = "easyeffects-preset-switcher";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
