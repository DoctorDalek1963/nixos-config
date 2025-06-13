{
  lib,
  config,
  ...
}: let
  theme =
    {
      "catppuccin-macchiato" = {
        default-fg = "#cad3f5"; # Text
        default-bg = "#1e2030"; # Mantle

        highlight-active-color = "rgba(138, 173, 244, 0.4)"; # Blue
        highlight-color = "rgba(125, 196, 228, 0.4)"; # Sapphire
      };
    }.${
      config.setup.terminal.theme
    };
in {
  config = lib.mkIf config.setup.misc.programs.zathura {
    programs.zathura = {
      enable = true;

      mappings = {
        c = "nohlsearch";
      };

      options =
        {
          guioptions = "sv"; # Statusbar and vertical scroll bar
          font = lib.mkIf config.setup.fonts.hackNerdFont "Hack Nerd Font 9";

          statusbar-home-tilde = true;

          synctex-editor-command = ''${config.consts.nvimPath} --headless -c \"VimtexInverseSearch %{line} '%{input}'\"'';
        }
        // theme;
    };
  };
}
