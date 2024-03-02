{...}: {
  programs.nixvim.plugins = {
    # Lots of good snippets for various languages
    friendly-snippets.enable = true;

    luasnip = {
      enable = true;
      # Load snippets from friendly-snippets
      fromVscode = [{}];
    };

    cmp-buffer.enable = true; # Words in the current buffer
    #cmp-dap.enable = true; # Debugging stuff
    cmp-latex-symbols.enable = true;
    cmp_luasnip.enable = true;
    cmp-nvim-lsp.enable = true; # Native LSP
    cmp-nvim-lua.enable = true; # Nvim Lua API
    cmp-path.enable = true; # Filepaths
    cmp-spell.enable = true; # English words

    nvim-cmp = {
      enable = true;

      autoEnableSources = false;
      sources = [
        {name = "buffer";}
        #{name = "dap";}
        {name = "latex_symbols";}
        {name = "luasnip";}
        {name = "nvim_lsp";}
        {name = "nvim_lua";}
        {name = "path";}
        {name = "spell";}
      ];

      snippet.expand = "luasnip";
      completion.completeopt = "menu,menuone,popup,noselect";

      mapping = {
        "<C-space>" = "cmp.mapping.complete()";
        "<CR>" = "cmp.mapping.confirm({ select = true })";
        "<Tab>" = {
          action = ''
            function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif require("luasnip").jumpable(1) then
                vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-next", true, true, true), "")
              else
                fallback()
              end
            end
          '';
          modes = [
            "i"
            "s"
          ];
        };
        "<S-Tab>" = {
          action = ''
            function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif require("luasnip").jumpable(-1) then
                vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
              else
                fallback()
              end
            end
          '';
          modes = [
            "i"
            "s"
          ];
        };
        "<down>" = {
          action = ''
            function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              else
                fallback()
              end
            end
          '';
          modes = ["i" "s"];
        };
        "<up>" = {
          action = ''
            function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              else
                fallback()
              end
            end
          '';
          modes = ["i" "s"];
        };
      };
    };
  };
}
