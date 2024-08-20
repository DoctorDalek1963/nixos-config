{
  pkgs,
  config,
  ...
}: {
  home = {
    inherit (config.setup) username;
    homeDirectory = "/home/${config.setup.username}";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "23.11"; # Please read the comment before changing.

    packages = with pkgs; [
      # wl-clipboard
      xclip
    ];

    file = {
      ".inputrc".text = ''
        $include /etc/inputrc
        "\C-H": backward-kill-word
      '';
      ".XCompose".text = ''
        include "%L"
        <Multi_key> <b> <c> : "∵" # because
        <Multi_key> <t> <f> : "∴" # therefore
      '';
    };
  };

  targets.genericLinux.enable = false;

  xdg.userDirs = let
    home = "${config.home.homeDirectory}";
  in {
    enable = true;
    createDirectories = true;

    download = "${home}/Downloads";
    music = "${home}/Music";
    pictures = "${home}/Pictures";
    videos = "${home}/Videos";

    desktop = null;
    documents = null;
    publicShare = null;
    templates = null;
  };

  # Stuff tends to collect in my Downloads, so I'm intentionally not persisting it
  setup.impermanence.keepDirs = ["Music" "Pictures" "Videos"];
}
