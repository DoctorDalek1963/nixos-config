{
  pkgs,
  lib,
  config,
  ...
}: let
  mp = config.setup.misc.programs;
in {
  imports = [./discord.nix ./evince.nix ./feishin.nix ./hexchat.nix ./ms-teams.nix ./xremap.nix];

  home.packages =
    lib.optional mp.handbrake pkgs.handbrake
    ++ lib.optional mp.obsidian pkgs.obsidian
    ++ lib.optional mp.rustdesk pkgs.rustdesk
    ++ lib.optional mp.vlc pkgs.vlc
    ++ lib.optional mp.zoom pkgs.zoom-us;

  setup.impermanence.keepDirs = lib.optionals mp.obsidian ["Obsidian" ".config/obsidian"];
}
