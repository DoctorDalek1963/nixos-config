{config, ...}: {
  programs.ripgrep = {
    enable = config.setup.terminalTools.ripgrep;
    arguments = [
      "--max-columns=150"
      "--max-columns-preview"
      "--glob=!.git/*"
      "--smart-case"
    ];
  };
}
