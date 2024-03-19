{config, ...}: {
  programs.btop = {
    enable = config.setup.terminalTools.btop;
    settings = {
      theme = "onedark";
      theme_background = false;
      update_ms = 500;
      proc_tree = true;
    };
  };
}
