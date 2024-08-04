{
  pkgs,
  lib,
  config,
}: let
  cfg = config.setup.firefox;
  addons = pkgs.nur.repos.rycee.firefox-addons;

  extensions =
    (with addons; [
      # Privacy
      duckduckgo-privacy-essentials
      privacy-badger
      ublock-origin
    ])
    ++ (lib.optionals (!cfg.minimal) (with addons; [
      # Programming
      github-file-icons
      refined-github
      rust-search-extension
      tampermonkey # Unfree

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
      wayback-machine
      whowrotethat
      zotero-connector
    ]));
in
  if cfg.enableExtensions
  then extensions
  else []
