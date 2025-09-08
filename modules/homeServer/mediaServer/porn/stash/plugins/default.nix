{ pkgs }:
let
  inherit (pkgs.stdenvNoCC) mkDerivation;
  inherit (pkgs) fetchFromGitHub;

  commonSrcs = {
    CommunityScripts = fetchFromGitHub {
      owner = "stashapp";
      repo = "CommunityScripts";
      rev = "c1151f670b49809da95df9ebc2bfed773cc6834e";
      hash = "sha256-MrfrYEuPFMuKlDo/qqZJKcjJd+7JRlMbADEg6Fvk3AM=";
    };

    serechops-stash = fetchFromGitHub {
      owner = "Serechops";
      repo = "Serechops-Stash";
      rev = "13cf83cd3599afc0c7c76a0854acef88b2bf4ff6";
      hash = "sha256-4vS0OV02A1UPbn6T1/6LLq9vGrJDfEX/0NmjJO6XkGE=";
    };
  };

  AudioPlayer = mkDerivation {
    name = "stash-plugin-AudioPlayer";
    dontBuild = true;

    src = commonSrcs.CommunityScripts;

    installPhase = ''
      mkdir $out
      cd plugins/AudioPlayer
      cp AudioPlayer.js AudioPlayer.css AudioPlayer.yml $out/
    '';
  };

  CommunityScriptsUILibrary = mkDerivation {
    name = "stash-plugin-CommunityScriptsUILibrary";
    dontBuild = true;

    src = commonSrcs.CommunityScripts;

    installPhase = ''
      mkdir $out
      cd plugins/CommunityScriptsUILibrary
      cp cs-ui-lib.js CommunityScriptsUILibrary.yml $out/
    '';
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

    cp -r ${AudioPlayer} $out/AudioPlayer
    cp -r ${CommunityScriptsUILibrary} $out/CommunityScriptsUILibrary
    cp -r ${renamer} $out/renamer
  '';
}
