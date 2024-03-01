{...}: {
  programs.nixvim.plugins = {
    # Rust tools: LSP, formatter, debugger
    # TODO: How does this integrate with my system rustup? What about toolchains?
    rustaceanvim = {
      enable = true;
      tools.hoverActions.replaceBuiltinHover = false;
    };

    lsp-format = {
      enable = true;
      lspServersToEnable = "all";
    };

    # See https://nix-community.github.io/nixvim/plugins/lsp/index.html for options and supported servers
    lsp = {
      enable = true;

      keymaps = {
        silent = true;
        lspBuf = {
          "<M-return>" = "code_action";
          "gd" = "definition";
          "<leader>f" = "format";
          "K" = "hover";
          "gi" = "implementation";
          "gr" = "references";
          "<leader>rn" = "rename";
          "gy" = "type_definition";
        };
        diagnostic = {
          "<leader>j" = "goto_next";
          "<leader>k" = "goto_prev";
        };
      };

      servers = {
        # Bash
        bashls.enable = true;

        # C/C++
        ccls.enable = true;

        # CSS
        cssls.enable = true;

        # Dockerfile
        dockerls.enable = true;

        # Haskell
        hls.enable = true;

        # HTML
        html.enable = true;

        # Java
        java-language-server.enable = true;

        # JSON
        jsonls.enable = true;

        # Julia
        julials.enable = true;

        # Kotlin
        kotlin-language-server.enable = true;

        # LaTeX
        # TODO: Make sure the LaTeX referrence manual is installed as an info node:
        # https://github.com/astoff/digestif/wiki/Common-installation-issues#info-nodes
        digestif.enable = true;

        # Lua
        lua-ls.enable = true;

        # Nix
        nixd = {
          enable = true;
          settings.formatting.command = "alejandra --quiet";
        };

        # Python
        ruff-lsp.enable = true; # Currently broken for some reason

        # TOML
        taplo.enable = true;

        # YAML
        yamlls.enable = true;

        # XML
        lemminx.enable = true;
      };
    };
  };
}
