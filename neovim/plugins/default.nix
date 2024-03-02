{...}: {
  imports = [
    ./cmp.nix
    ./lightline.nix
    ./lsp.nix
  ];

  programs.nixvim.plugins = {
    # Show diff signs in the left column
    gitgutter.enable = true;

    # For markdown files
    goyo.enable = true;

    # Show indentation levels
    indent-blankline = {
      enable = true;
      scope.enabled = false;
    };

    # Resume editing from the last place
    lastplace.enable = true;

    # Rainbow brackets and tags
    rainbow-delimiters.enable = true;

    # Handle delimiters like () [] {} "" '' better
    surround.enable = true;

    # Treesitter grammar
    treesitter = {
      enable = true;
      ensureInstalled = "all";
      folding = true;
      indent = true;
    };

    # Add scope context with treesitter
    treesitter-context.enable = true;

    # Make matching tags like () [] {} "" '' work better
    vim-matchup = {
      enable = true;
      treesitterIntegration.enable = true;
      matchParen.offscreen = {
        method = "popup";
        scrolloff = true;
      };
    };

    # Integrate LaTeX
    vimtex = {
      enable = true;
      # Use the texlive installed system-wide
      texlivePackage = null;
    };
  };
}
