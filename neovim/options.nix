{...}: let
  baseOptions = {
    # Line numbers
    number = true;
    relativenumber = true;
    ruler = true;

    # Searching
    ignorecase = true;
    smartcase = true;
    hlsearch = true;
    incsearch = true;

    # Highlight the line where the cursor is
    cursorline = true;

    # Show spaces and tabs
    list = true;
    listchars = {
      trail = "·";
      nbsp = "~";
      tab = ">-";
    };

    # Spacing
    tabstop = 4;
    shiftwidth = 4;
    expandtab = false;

    # Folds
    foldenable = true;
    #foldmethod = "indent"; # Disabled because we're using treesitter
    foldlevelstart = 999;

    # Indents
    autoindent = true;
    smartindent = true;

    # Reload the file if it's been changed outside of nvim
    autoread = true;

    # Use British English for spell checking
    spelllang = "en_gb";

    # Never hide things
    conceallevel = 0;

    # Keep two lines of context around the cursor line
    scrolloff = 2;

    # Only allow the mouse in normal mode
    mouse = "n";
  };
  pluginOptions = {
    # Make lightline look better
    laststatus = 2;
    showmode = false;

    # Backups can mess with LSPs
    backup = false;
    writebackup = false;

    # Faster updates make gitgutter work better
    updatetime = 100;

    # Always draw the sign column
    signcolumn = "yes";
  };
in {
  programs.nixvim.options = baseOptions // pluginOptions;
}
