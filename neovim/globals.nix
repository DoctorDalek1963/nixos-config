{...}: let
  baseGlobals = {
    mapleader = "\\";
    maplocalleader = "\\";
  };
  pluginGlobals = {
    onedark_terminal_italics = 1;
  };
in {
  programs.nixvim.globals = baseGlobals // pluginGlobals;
}
