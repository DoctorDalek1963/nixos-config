{...}: let
  baseGlobals = {
    mapleader = "\\";
    maplocalleader = "\\";
  };
  pluginGlobals = {
    # Onedark
    onedark_terminal_italics = 1;

    # vimtex
    vimtex_view_general_viewer = "evince";
    vimtex_syntax_conceal_disable = 1;
  };
in {
  programs.nixvim.globals = baseGlobals // pluginGlobals;
}
