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

    sneakyninja-stash-plugins = fetchFromGitHub {
      owner = "sneakyninja256";
      repo = "stash-plugins";
      rev = "6597262c060faa867df7e218088ad1bcf0f01dc1";
      hash = "sha256-gjePXhzDAYJUvHTznSbovgzpY06BattulsQzGZwjEyE=";
    };
  };

  AudioPlayerLite = mkDerivation {
    name = "stash-plugin-AudioPlayerLite";
    dontBuild = true;

    patches = [ ./AudioPlayerLite/css.patch ];
    src = commonSrcs.CommunityScripts;

    installPhase = ''
      mkdir $out
      cd plugins/AudioPlayerLite
      cp AudioPlayerLite.js AudioPlayerLite.css AudioPlayerLite.yml $out/
    '';
  };

  # Requires CommunityScriptsUILibrary
  audioTab = mkDerivation {
    name = "stash-plugin-audioTab";
    dontBuild = true;

    src = commonSrcs.sneakyninja-stash-plugins;

    installPhase = ''
      mkdir $out
      cd plugins/audioTab
      cp audioTab.js audioTab.yml $out/
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

    cp -r ${AudioPlayerLite} $out/AudioPlayerLite
    cp -r ${audioTab} $out/audioTab
    cp -r ${CommunityScriptsUILibrary} $out/CommunityScriptsUILibrary
    cp -r ${renamer} $out/renamer
  '';
}
