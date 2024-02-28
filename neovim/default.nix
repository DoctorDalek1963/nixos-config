{...}: {
  imports = [
    ./autoCmdGroups.nix
    ./keymaps.nix
    ./options.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    clipboard.register = "unnamedplus";

    globals = {
      mapleader = "\\";
      maplocalleader = "\\";
    };

    userCommands = {
      Rmsp = {
        desc = "Remove all trailing spaces";
        command = "execute '%s/\\s\\+$//e'";
      };
    };

    highlight = {
      CocHintSign.link = "Comment";
    };
  };
}
