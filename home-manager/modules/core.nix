{
  lib,
  config,
  osConfig,
  ...
}:
{
  home = {
    inherit (config.setup) username;
    homeDirectory = "/home/${config.setup.username}";

    stateVersion = "25.11";

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

  xdg = {
    enable = true;

    userDirs =
      let
        home = "${config.home.homeDirectory}";
      in
      {
        enable = osConfig.setup.isGraphical;
        createDirectories = true;

        documents = "${home}/Documents";
        download = "${home}/Downloads";
        music = "${home}/Music";
        pictures = "${home}/Pictures";
        videos = "${home}/Videos";

        desktop = null;
        publicShare = null;
        templates = null;
      };
  };

  # Stuff tends to collect in my Downloads, so I'm intentionally not persisting it
  setup.impermanence.keepDirs = lib.mkIf osConfig.setup.isGraphical [
    "Documents"
    "Music"
    "Pictures"
    "Videos"
  ];
}
