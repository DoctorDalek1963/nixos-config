{
  pkgs,
  lib,
  config,
}: let
  cfg = config.setup.librewolf;
  addons = pkgs.nur.repos.rycee.firefox-addons;

  extensions =
    (with addons; [
      # Privacy
      canvasblocker
      duckduckgo-privacy-essentials
      privacy-badger
      # ublock-origin # Included by default with LibreWolf with extra block lists
    ])
    ++ (lib.optionals (!cfg.minimal) (with addons; [
      # Programming
      violentmonkey

      # YouTube
      dearrow
      enhancer-for-youtube # Unfree
      leechblock-ng
      return-youtube-dislikes
      sponsorblock

      # Misc
      darkreader
      dashlane # Unfree
      foxyproxy-standard
      vimium
      wayback-machine
      zotero-connector
    ]));
in
  if cfg.enableExtensions
  then extensions
  else []
