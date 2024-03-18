{
  config,
  pkgs,
  lib,
  #unstable,
  my-nixvim,
  username,
  homedir,
  ...
}: {
  home = {
    inherit username;
    homeDirectory = homedir;

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "23.11"; # Please read the comment before changing.

    packages = with pkgs; [
      my-nixvim

      delta # Needed for git
      fd
      sad
      sd
      tldr
      vim

      (nerdfonts.override {fonts = ["Hack"];})
    ];

    file = {
      ".git-prompt.sh".source = "${pkgs.fetchFromGitHub {
        owner = "git";
        repo = "git";
        rev = "fc134b41ce2ee7b2a98a988db6eeb109e11a2831";
        hash = "sha256-vL2zpDQJ7vJBrBflPqPUMPFP+tu8K79LbojtUGzFUMw=";
        sparseCheckout = ["contrib/completion/git-prompt.sh"];
      }}/contrib/completion/git-prompt.sh";
      ".inputrc".text = ''
        $include /etc/inputrc
        "\C-H": backward-kill-word
      '';
      ".XCompose".text = ''
        include "%L"
        <Multi_key> <b> <c> : "∵" # because
        <Multi_key> <t> <f> : "∴" # therefore
      '';
    };

    sessionVariables = {
      EDITOR = "${my-nixvim}/bin/nvim";
      EXTENDED_PS1 = 1;
    };
  };

  xdg.configFile = {
    "fd/ignore".text = ''
      .git/*
      .cache/*
      OneDrive/*
      *.pyc
    '';
  };

  nixpkgs.config = {
    # These are lists of allowed unfree and insecure packages respectively.
    # They are allowed on any host (since this is core.nix), but they're
    # only actually installed by certain modules.

    # TODO: Why does firefox-addons not respect this? Even if allowUnfree = true, it still complains
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) ["obsidian" "tampermonkey"];

    permittedInsecurePackages = [
      "electron-25.9.0" # Needed by obsidian
    ];
  };

  nix = {
    package = pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };

  targets.genericLinux.enable = true;

  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;

    bat = {
      enable = true;
      config = {
        theme = "OneHalfDark";
        italic-text = "always";
      };
      syntaxes = {
        just = {
          src = pkgs.fetchFromGitHub {
            owner = "nk9";
            repo = "just_sublime";
            rev = "352bae277961d41e2a1795a834dbf22661c8910f";
            hash = "sha256-QCp6ypSBhgGZG4T7fNiFfCgZIVJoDSoJBkpcdw3aiuQ=";
          };
          file = "Syntax/Just.sublime-syntax";
        };
        ron = {
          src = pkgs.fetchFromGitHub {
            owner = "ron-rs";
            repo = "sublime-ron";
            rev = "41e3e37db9febbf9dfc4efad015934c61b3c8ef1";
            hash = "sha256-t7ILpYizGIoICKe3NzBkeb9fzou0d7NkyDjLIUsa9KE=";
          };
          file = "RON.sublime-syntax";
        };
        wolfram = {
          src = pkgs.fetchFromGitHub {
            owner = "WolframResearch";
            repo = "Sublime-WolframLanguage";
            rev = "1d2da4b347a03d07e1b816a25a02c1a992230d3a";
            hash = "sha256-9MaD96xBAHF4ubuvoqMz3uJGUHE36lIiuOjJkAAucTI=";
          };
          file = "WolframLanguage.sublime-syntax";
        };
      };
    };

    btop = {
      enable = true;
      settings = {
        theme = "onedark";
        theme_background = false;
        update_ms = 500;
        proc_tree = true;
      };
    };

    ripgrep = {
      enable = true;
      arguments = [
        "--max-columns=150"
        "--max-columns-preview"
        "--glob=!.git/*"
        "--smart-case"
      ];
    };

    git = {
      enable = true;
      userName = "DoctorDalek1963";
      userEmail = "dyson.dyson@icloud.com";
      aliases = {
        a = "add";
        aa = "add -A";
        ae = "add -e";
        aea = "add -e -A";
        ap = "add -p";
        apa = "add -p -A";
        br = "branch";
        c = "commit";
        ca = "commit -a";
        cam = "commit -a -m";
        cane = "commit --amend --no-edit";
        cm = "commit -m";
        co = "checkout";
        cob = "checkout -b";
        fixm = "commit --amend";
        l = "log";
        la = "log --all --decorate";
        last = "log -1 HEAD";
        lg = "log --all --graph --oneline --decorate --notes --date-order";
        lo = "log --oneline";
        pfwl = "push --force-with-lease";
        puom = "push -u origin main";
        sh = "show";
        st = "status";
        sw = "switch";
        unstage = "restore --staged";
        uncommit = "reset --soft HEAD~1";
      };
      signing = {
        key = "${homedir}/.ssh/git_main_signing";
        signByDefault = true;
      };
      delta = {
        enable = true;
        options = {
          navigate = true;
          light = false;
          syntax-theme = "OneHalfDark";
          line-numbers = true;
        };
      };
      extraConfig = {
        core.editor = "${my-nixvim}/bin/nvim";
        diff.colorMoved = "default";
        fetch.prune = true;
        gpg.format = "ssh";
        init.defaultBranch = "main";
        merge.ff = false;
        pull = {
          rebase = false;
          ff = "only";
        };
        push = {
          followTags = true;
          autoSetupRemote = true;
          default = "current";
        };
      };
    };
  };
}
