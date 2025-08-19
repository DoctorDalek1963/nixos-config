{
  pkgs,
  lib,
  config,
  ...
}:
let
  mp = config.setup.misc.programs;
in
{
  imports = [
    ./anki.nix
    ./discord.nix
    ./evince.nix
    ./feishin.nix
    ./hexchat.nix
    ./loupe.nix
    ./mediaCuration.nix
    ./ms-teams.nix
    ./obsidian.nix
    ./xremap.nix
    ./zathura.nix
  ];

  home.packages =
    lib.optional mp.handbrake pkgs.handbrake
    ++ lib.optional mp.obsidian pkgs.obsidian
    ++ lib.optional mp.rustdesk pkgs.rustdesk
    ++ lib.optional mp.vlc pkgs.vlc
    ++ lib.optional mp.zoom pkgs.zoom-us;
}
