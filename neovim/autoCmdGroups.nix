{...}: let
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
        {
          desc = "Enable Goyo";
          event = "FileType";
          pattern = "markdown";
          command = "Goyo 80";
        }
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
      group = "update_git_ps1_status";
      commands = [
        {
          desc = "Update the git_ps1_status global variable by calling UpdateGitPS1Status()";
          event = ["BufEnter" "BufWritePost"];
          pattern = "*";
          command = "call UpdateGitPS1Status()";
        }
      ];
    }
    {
      group = "filetypes";
      commands = filetypeCommands;
    }
  ];
  filetypeCommands = builtins.attrValues (builtins.mapAttrs (filetype: extension: {
      desc = "Set filetype for ${filetype} files";
      event = ["BufNewFile" "BufReadPre"];
      pattern =
        if builtins.isList extension
        then builtins.map (ext: "*.${ext}") extension
        else "*.${extension}";
      command = "setf ${filetype}";
    }) {
      apl = ["apl" "dyag" "dyalog"];
      brainfuck = ["bf" "brainfuck"];
      coq = "v";
      nasm = "nasm";
      sage = "sage";
      tex = "tex";
    });
in {
  programs.nixvim.autoCmd =
    builtins.concatMap
    (def: builtins.map (command: command // {group = "${def.group}_augroup";}) def.commands)
    autoCmdGroups;

  programs.nixvim.autoGroups =
    builtins.foldl'
    (acc: elem: acc // elem)
    {}
    (builtins.map (def: {"${def.group}_augroup" = {clear = true;};}) autoCmdGroups);
}
