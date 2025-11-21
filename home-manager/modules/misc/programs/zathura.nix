{
  lib,
  config,
  ...
}:
let
  theme =
    {
      # Taken mostly from https://github.com/catppuccin/zathura/blob/main/src/catppuccin-macchiato
      "catppuccin-macchiato" = {
        default-fg = "rgba(202, 211, 245, 1)";
        default-bg = "rgba(30, 32, 48, 1)";

        completion-bg = "rgba(54, 58, 79, 1)";
        completion-fg = "rgba(202, 211, 245, 1)";
        completion-highlight-bg = "rgba(87, 82, 104, 1)";
        completion-highlight-fg = "rgba(202, 211, 245, 1)";
        completion-group-bg = "rgba(54, 58, 79, 1)";
        completion-group-fg = "rgba(138, 173, 244, 1)";

        statusbar-fg = "rgba(202, 211, 245, 1)";
        statusbar-bg = "rgba(54, 58, 79, 1)";

        notification-bg = "rgba(54, 58, 79, 1)";
        notification-fg = "rgba(202, 211, 245, 1)";
        notification-error-bg = "rgba(54, 58, 79, 1)";
        notification-error-fg = "rgba(237, 135, 150, 1)";
        notification-warning-bg = "rgba(54, 58, 79, 1)";
        notification-warning-fg = "rgba(250, 227, 176, 1)";

        inputbar-fg = "rgba(202, 211, 245, 1)";
        inputbar-bg = "rgba(54, 58, 79, 1)";

        recolor = false;
        recolor-lightcolor = "rgba(36, 39, 58, 1)";
        recolor-darkcolor = "rgba(202, 211, 245, 1)";
        recolor-keephue = true;

        index-fg = "rgba(202, 211, 245, 1)";
        index-bg = "rgba(36, 39, 58, 1)";
        index-active-fg = "rgba(202, 211, 245, 1)";
        index-active-bg = "rgba(54, 58, 79, 1)";

        render-loading-bg = "rgba(36, 39, 58, 1)";
        render-loading-fg = "rgba(202, 211, 245, 1)";

        highlight-color = "rgba(87, 82, 104, 0.4)";
        highlight-fg = "rgba(245, 189, 230, 0.4)";
        highlight-active-color = "rgba(245, 189, 230, 0.4)";
      };
    }
    .${config.setup.terminal.theme};
in
{
  config = lib.mkIf config.setup.misc.programs.zathura {
    programs.zathura = {
      enable = true;

      mappings = {
        c = "nohlsearch";
      };

      options = {
        guioptions = "sv"; # Statusbar and vertical scroll bar
        font = lib.mkIf config.setup.fonts.hackNerdFont "Hack Nerd Font 9";

        selection-clipboard = "clipboard";
        statusbar-home-tilde = true;

        synctex-editor-command = ''${config.setup.shared.nvim.path} --headless -c \"VimtexInverseSearch %{line} '%{input}'\"'';
      }
      // theme;
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = [ "org.pwmt.zathura.desktop" ];
      };
    };
  };
}
