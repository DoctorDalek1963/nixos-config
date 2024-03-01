{...}: {
  programs.nixvim.plugins.lsp-format = {
    enable = true;
    lspServersToEnable = "all";
  };

  programs.nixvim.plugins.lsp = {
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

      # Nix
      nixd = {
        enable = true;
        settings.formatting.command = "alejandra --quiet";
      };

      # Python
      ruff-lsp.enable = true; # Currently broken for some reason
    };
  };
}
