{nixvim, ...}: let
  autoCmdGroups = [
    {
      group = "tabs";
      commands = [
        {
          desc = "Expand tabs to spaces";
          event = "FileType";
          pattern = ["haskell" "nix" "python" "rst"];
          command = "setlocal expandtab";
        }
        {
          desc = "Set a tab to be 2 spaces";
          event = "FileType";
          pattern = ["haskell" "nix"];
          command = "setlocal shiftwidth=2 tabstop=2";
        }
        {
          desc = "Set a tab to be 2 spaces";
          event = "FileType";
          pattern = "rst";
          command = "setlocal shiftwidth=3 tabstop=3";
        }
      ];
    }
    {
      group = "plaintext";
      commands = [
        {
          desc = "Enable spell check in plain text files";
          event = "FileType";
          pattern = ["markdown" "rst" "tex" "text"];
          command = "setlocal spell";
        }
        {
          desc = "Enable word wrapping in plain text files";
          event = "FileType";
          pattern = ["markdown" "rst" "tex" "text"];
          command = "setlocal linebreak";
        }
      ];
    }
    {
      group = "markdown";
      commands = [
        {
          desc = "Set the textwidth and formatoptions for markdown files";
          event = "FileType";
          pattern = "markdown";
          command = "setlocal textwidth=0 formatoptions=q";
        }
        #{
        #desc = "Enable Goyo";
        #event = "FileType";
        #pattern = "markdown";
        #command = "Goyo 80";
        #}
        #{
        #desc = "Enable SoftPencil";
        #event = "FileType";
        #pattern = "markdown";
        #command = "SoftPencil";
        #}
      ];
    }
    {
      group = "python";
      commands = [
        {
          desc = "Set colour column at 120 lines";
          event = "FileType";
          pattern = "python";
          command = "setlocal colorcolumn=120";
        }
      ];
    }
    {
      group = "rust";
      commands = [
        {
          desc = "Create mapping for formatting";
          event = "FileType";
          pattern = "rust";
          command = "nnoremap <silent> <leader>f <cmd>RustFmt<cr>";
        }
      ];
    }
    {
      group = "resume_cursor_position";
      commands = [
        {
          # Adapted from https://stackoverflow.com/a/3699926/12985838
          desc = "Resume cursor position, expand folds up to cursor line, and centre cursor line on the screen";
          event = "BufReadPost";
          pattern = "*";
          command = ''if line("'\"") > 0 && line ("'\"") <= line("$") | exe "normal g'\"" | exe "normal zv" | exe "normal zz" | endif'';
        }
      ];
    }
    {
      group = "filetypes";
      commands = [
        {
          desc = "Set tex filetype";
          event = ["BufNewFile" "BufReadPre"];
          pattern = "*.tex";
          command = "setf tex";
        }
        # TODO: Add more of these (but automate it)
      ];
    }
  ];
in {
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    clipboard.register = "unnamedplus";

    globals = {
      mapleader = "\\";
      maplocalleader = "\\";
    };

    options = {
      # Line numbers
      number = true;
      relativenumber = true;
      ruler = true;

      # Searching
      ignorecase = true;
      smartcase = true;
      hlsearch = true;
      incsearch = true;

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
      foldmethod = "indent";
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

    keymaps = [
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
    ];

    autoCmd =
      builtins.concatMap
      (def: builtins.map (command: command // {group = "${def.group}_augroup";}) def.commands)
      autoCmdGroups;

    autoGroups =
      builtins.foldl'
      (acc: elem: acc // elem)
      {}
      (builtins.map (def: {"${def.group}_augroup" = {clear = true;};}) autoCmdGroups);

    userCommands = {
      Rmsp = {
        desc = "Remove all trailing spaces";
        command = "execute '%s/\\s\\+$//e'";
      };
    };

    highlight = {
      CocHintSign.link = "Comment";
    };

    #filetype = {
    #pattern = {
    #".*\\.(apl|dya(lo)?g)" = "apl";
    #};
    #extension = {
    #bf = "brainfuck";
    #brainfuck = "brainfuck";
    #nasm = "nasm";
    #sage = "sage";
    #};
    #};
  };
}
