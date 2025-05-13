{pkgs}: let
  inherit (pkgs.stdenvNoCC) mkDerivation;
  inherit (pkgs) fetchFromGitHub;

  commonSrcs = {
    serechops-stash = fetchFromGitHub {
      owner = "Serechops";
      repo = "Serechops-Stash";
      rev = "13cf83cd3599afc0c7c76a0854acef88b2bf4ff6";
      hash = "sha256-4vS0OV02A1UPbn6T1/6LLq9vGrJDfEX/0NmjJO6XkGE=";
    };
  };

  renamer = mkDerivation {
    name = "stash-plugin-renamer";
    dontBuild = true;

    patches = [
      ./renamer/api-key.patch
      ./renamer/separator.patch
    ];
    src = commonSrcs.serechops-stash;

    installPhase = ''
      mkdir $out
      cd plugins/Renamer
      cp renamer.py renamer.yml $out/
      cp ${./renamer/settings.py} $out/renamer_settings.py
    '';
  };
in
  mkDerivation {
    name = "stash-plugins";

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      mkdir $out

      cp -r ${renamer} $out/renamer
    '';
  }
