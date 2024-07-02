# This script was adapted from nixpkgs' Readarr definition
{
  stdenvNoCC,
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  nixosTests,
  dotnetCorePackages,
  readarr,
  fd,
  imagemagick,
  rename,
  sd,
  sqlite,
  mkYarnPackage,
}: let
  inherit (readarr) version;

  dotnet-runtime = dotnetCorePackages.aspnetcore_6_0;

  prePatchedSource = stdenvNoCC.mkDerivation {
    name = "speakarr-${version}-pre-patched-source";

    src = fetchFromGitHub {
      owner = "Readarr";
      repo = "Readarr";
      rev = "v${version}";
      hash = "sha256-ZLY7GjK5/+AkUjlVKBfQbOT2woJDyETLdXB8+uEnQCk=";
    };

    nativeBuildInputs = [
      fd
      imagemagick
      rename
      sd
    ];

    patches = [
      ./colours.patch
      ./port.patch
      ./warnings-as-errors.patch
    ];

    buildPhase = ''
      fd -X sd --flags c "readarr" "speakarr"
      fd -X sd --flags c "Readarr" "Speakarr"
      fd -X sd --flags c "READARR" "SPEAKARR"

      fd -X sd --flags c "speakarr.servarr.com" "readarr.servarr.com"

      fd -t d readarr -X rename 's/readarr/speakarr/g'
      fd -t d readarr -X rename 's/Readarr/Speakarr/g'
      fd -t f readarr -X rename 's/readarr/speakarr/g'
      fd -t f readarr -X rename 's/Readarr/Speakarr/g'

      cp ${./logo.svg} frontend/src/Content/Images/logo.svg
      convert -geometry 16x16 ${./logo.svg} frontend/src/Content/Images/Icons/favicon-16x16.png
      convert -geometry 32x32 ${./logo.svg} frontend/src/Content/Images/Icons/favicon-32x32.png
      convert -geometry 48x48 ${./logo.svg} frontend/src/Content/Images/Icons/favicon.ico
    '';

    installPhase = ''
      mkdir -p $out
      cp -rv . $out/
    '';
  };

  frontend = mkYarnPackage {
    pname = "speakarr-frontend";
    inherit version;

    src = prePatchedSource;

    # Run these commands to generate yarn.lock and yarn.nix, in the prePatchedSource:
    # yarn install
    # yarn2nix

    packageJSON = "${prePatchedSource}/package.json";
    yarnLock = ./yarn.lock;
    yarnNix = ./yarn.nix;

    installPhase = ''
      yarn build
      mkdir -p $out/share
      cp -rv node_modules/speakarr/_output/UI $out/share/UI
    '';

    doDist = false;
  };
in
  buildDotnetModule {
    pname = "speakarr";
    inherit version;

    src = prePatchedSource;

    projectFile = "src/Speakarr.sln";
    # installPath = "$out/share/speakarr-$version";
    executables = ["Speakarr"];
    nugetDeps = ./nuget-deps.nix;

    dotnetBuildFlags = ["-p:Deterministic=false"];
    dotnetInstallFlags = ["--framework=net6.0"];

    inherit dotnet-runtime;

    runtimeDeps = [sqlite];

    # buildDotnetModule generates its own NuGet.config, so we need to remove
    # this one to avoid conflicts
    preConfigure = ''
      rm src/NuGet.config
    '';

    postInstall = ''
      cp -rv ${frontend}/share/UI $out/lib/speakarr/
    '';

    passthru = {
      # Fetch the dependencies to generate nuget-deps.nix like so, in the prePatchedSource:
      # dotnet clean src/Speakarr.sln -c Release
      # dotnet restore src/Speakarr.sln -p:Configuration=Release -p:Platform=Posix -t:PublishAllRids --packages nuget-pkgs
      # nuget2nix --directory nuget-pkgs/ --nuget-config src/NuGet.config > nuget-deps.nix
      # Where nuget2nix comes from the flake at github:winterqt/nuget2nix

      # updateScript = ./update.sh;
      tests.smoke-test = nixosTests.readarr;
    };

    meta = {
      description = "A Usenet/BitTorrent audiobook downloader";
      homepage = "https://readarr.com";
      license = lib.licenses.gpl3;
      maintainers = [lib.maintainers.jocelynthode];
      mainProgram = "Speakarr";
      inherit (dotnet-runtime.meta) platforms;
    };
  }
