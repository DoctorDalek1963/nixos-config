{...}: {
  programs.nixvim.plugins = {
    # Lots of good snippets for various languages
    friendly-snippets.enable = true;

    luasnip = {
      enable = true;
      # Load snippets from friendly-snippets
      fromVscode = [{}];
    };
    cmp_luasnip.enable = true;

    nvim-cmp = {
      enable = true;

      autoEnableSources = false;
      sources = [
        #{ name = "nvim_lsp"; }
        {name = "luasnip";}
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
