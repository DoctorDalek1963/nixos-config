{...}: let
  baseKeymaps = [
    # Quit vim
    {
      key = "<leader>q";
      action = "<cmd>qa<cr>";
      mode = "n";
    }
    # Force quit
    {
      key = "<leader>Q";
      action = "<cmd>qa!<cr>";
    }

    # Write all open files
    {
      key = "<leader>w";
      action = "<cmd>wa<cr>";
      mode = "n";
    }
    # Write all open files and quit
    {
      key = "<leader>W";
      action = "<cmd>wqa<cr>";
      mode = "n";
    }

    # Write current file
    {
      key = "<leader><leader>";
      action = "<cmd>w<cr>";
      mode = "n";
    }

    # Easier directional navigation between panes
    {
      key = "<C-j>";
      action = "<C-w>j";
      mode = "n";
    }
    {
      key = "<C-k>";
      action = "<C-w>k";
      mode = "n";
    }
    {
      key = "<C-h>";
      action = "<C-w>h";
      mode = "n";
    }
    {
      key = "<C-l>";
      action = "<C-w>l";
      mode = "n";
    }

    # Easier splitting into new panes
    # Open empty buffer by default
    {
      key = "<Bar>";
      action = "<C-w>v<C-w>l<C-w>n<C-w>j<C-w>c";
      mode = "n";
    }
    {
      key = "-";
      action = "<C-w>n<C-w>x<C-w>j";
      mode = "n";
    }

    # Open current file with leader
    {
      key = "<leader><Bar>";
      action = "<C-w>v<C-w>l";
      mode = "n";
    }
    {
      key = "<leader>-";
      action = "<C-w>s<C-w>j";
      mode = "n";
    }

    # Run current file
    {
      key = "<leader>r";
      action = ''<cmd>!"%:p"<cr>'';
      mode = "n";
    }

    # Clear the terminal and run the current file
    {
      key = "<leader>R";
      action = ''<cmd>!clear<cr><cr><cmd>"%:p"<cr>'';
      mode = "n";
    }

    # Run current file with arguments
    {
      key = "<leader>A";
      action = ''<cmd>!"%:p" '';
      mode = "n";
    }

    # Duplicate the current line
    {
      key = "<C-d>";
      action = "yyp";
      mode = "n";
    }

    # Don't skip wrapped lines with arrow keys
    {
      key = "<up>";
      action = "g<up>";
      mode = "n";
    }
    {
      key = "<down>";
      action = "g<down>";
      mode = "n";
    }

    # Toggle folds with space
    {
      key = "<space><space>";
      action = "za";
      mode = "n";
    }
    {
      key = "<leader><space>";
      action = "zA";
      mode = "n";
    }

    # Clear the terminal
    {
      key = "<leader>cl";
      action = "<cmd>!clear<cr><cr>";
      mode = "n";
    }

    # Remove search highlight
    {
      key = "<leader>cl";
      action = "<cmd>!clear<cr><cr>";
      mode = "n";
      options.silent = true;
    }

    # Add a semicolon or comma to the end of a line
    {
      key = "<leader>;";
      action = "mqA;<esc>`q";
      mode = "n";
    }
    {
      key = "<leader>,";
      action = "mqA,<esc>`q";
      mode = "n";
    }

    # Add a colon to the end of the line and start a new line
    {
      key = "<leader>:";
      action = "A:<esc>o";
      mode = "n";
    }

    # Always use very magic regex mode
    {
      key = "/";
      action = "/\\v";
      mode = "n";
    }

    # Turn off highlighting after a search
    {
      key = "<leader>n";
      action = "<cmd>nohlsearch<cr>";
      mode = "n";
    }

    # Toggle spell check
    {
      key = "<leader>s";
      action = "<cmd>set spell!<cr>";
      mode = "n";
      options.silent = true;
    }

    # Automatically fix spelling
    {
      key = "<leader>z";
      action = "mq1z=`q";
      mode = "n";
      options.silent = true;
    }

    # Copy whole buffer to system clipboard
    {
      key = "<leader>cp";
      action = "<cmd>w !xclip -selection c<cr><cr>";
      mode = "n";
    }

    # Copy selected text to system clipboard
    {
      key = "<leader>cp";
      action = ''"+y'';
      mode = "v";
    }

    # Don't overwrite the default yank buffer when pasting
    {
      key = "p";
      action = "pgvy";
      mode = "v";
    }

    # Select everything in the buffer
    {
      key = "<leader>a";
      action = "ggVG";
      mode = "n";
    }

    # Toggle virtual text
    {
      key = "<leader>v";
      action = ''
        function()
          local vt = vim.diagnostic.config().virtual_text
          vim.diagnostic.config({ virtual_text = not vt })
        end
      '';
      lua = true;
      mode = "n";
      options.silent = true;
    }

    # Toggle inlay hints
    {
      key = "<leader>i";
      action = ''
        function()
          vim.lsp.inlay_hint.enable(vim.fn.bufnr(), not vim.lsp.inlay_hint.is_enabled())
        end
      '';
      lua = true;
      mode = "n";
      options.silent = true;
    }
  ];
  pluginKeymaps = [];
in {
  programs.nixvim.keymaps = baseKeymaps ++ pluginKeymaps;
}
