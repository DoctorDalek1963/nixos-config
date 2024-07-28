{
  pkgs,
  config,
}: let
  extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    # Privacy
    duckduckgo-privacy-essentials
    privacy-badger
    ublock-origin

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
  ];
in
  if config.setup.firefox.enableExtensions
  then extensions
  else []
