{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.setup.terminal.tools.btop;

  package =
    if cfg.gpuSupport
    then
      pkgs.btop.override {
        cudaSupport = true;
        rocmSupport = true;
      }
    else pkgs.btop;

  theme =
    {
      onedark = {
        name = "onedark";
        theme-file = null;
      };
      catppuccin-macchiato = {
        name = "catppuccin-macchiato";
        theme-file = {
          "btop/themes/catppuccin-macchiato.theme".source = "${pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "btop";
            rev = "c6469190f2ecf25f017d6120bf4e050e6b1d17af";
            hash = "sha256-Mdl0S68mkgeOGIJDpXpFXWpTBIAr6xSXcAxnUjay1iE=";
            sparseCheckout = ["themes/catppuccin_macchiato.theme"];
          }}/themes/catppuccin_macchiato.theme";
        };
      };
    }
    .${config.setup.terminal.theme};
in {
  config = lib.mkIf cfg.enable {
    programs.btop = {
      enable = true;
      inherit package;
      settings = {
        color_theme = theme.name;
        theme_background = true;
        update_ms = 500;
        proc_tree = true;
      };
    };

    xdg.configFile = lib.mkIf (theme.theme-file != null) theme.theme-file;
  };
}
