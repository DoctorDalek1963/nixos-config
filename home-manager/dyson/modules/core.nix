{
  config,
  pkgs,
  lib,
  #unstable,
  nixvim-flake,
  system,
  ...
}: let
  username = "dyson";
  homedir = "/home/${username}";
  my-nixvim = nixvim-flake.packages.${system}.default;
in {
  fonts.fontconfig.enable = true;

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

      fd
      sd
      tldr
      vim

      (nerdfonts.override {fonts = ["Hack"];})
    ];

    file = {
      ".config/fd/ignore".text = ''
        .git/*
        .cache/*
        OneDrive/*
        *.pyc
      '';
      ".git-prompt.sh".source = "${pkgs.fetchFromGitHub {
        owner = "git";
        repo = "git";
        rev = "fc134b41ce2ee7b2a98a988db6eeb109e11a2831";
        hash = "sha256-vL2zpDQJ7vJBrBflPqPUMPFP+tu8K79LbojtUGzFUMw=";
        sparseCheckout = ["contrib/completion/git-prompt.sh"];
      }}/contrib/completion/git-prompt.sh";
    };

    sessionVariables = {
      EDITOR = "${my-nixvim}/bin/nvim";
      EXTENDED_PS1 = 1;
    };
  };

  nixpkgs.config = {
    # These are lists of allowed unfree and insecure packages respectively.
    # They are allowed on any host (since this is core.nix), but they're
    # only actually installed by certain modules.

    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) ["obsidian"];

    permittedInsecurePackages = [
      "electron-25.9.0" # Needed by obsidian
    ];
  };

  nix = {
    package = pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };

  targets.genericLinux.enable = true;

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

    # Shell
    bash = {
      enable = true;
      enableCompletion = true;
      historySize = 1000;
      historyFileSize = -1;
      historyControl = [
        "ignoredups"
        "ignorespace"
      ];
      shellOptions = [
        "histappend"
        "checkwinsize"
        "extglob"
        "globstar"
        "checkjobs"
      ];
      shellAliases = {
        # Basics
        grep = "grep --color=auto";
        diff = "diff --color=auto";
        ls = "ls --color=auto";
        ll = "ls -la";
        la = "ls -a";
        lh = "ls -lah";

        # NixOS management
        cdnc = "cd /etc/nixos";
        cdhm = "cd /etc/nixos/home-manager/${username}";
        home-manager = "nix run /etc/nixos/home-manager/${username} -- --flake /etc/nixos/home-manager/${username}";

        # Single letters
        b = "bat";
        c = "cat";
        g = "git";
        j = "just";
        p = "python3";
        t = "touch";
        v = "${my-nixvim}/bin/nvim";
        x = "exit";

        # Two letters
        ca = "cargo";
        cl = "clear";
        jl = "julia";
        ps = "ps auxf";
        rm = "rm -v";
        rs = "evcxr";

        nvim-dev = "nix run ${homedir}/repos/nixvim-config --";

        ipy = "python3 -m IPython";
        jnb = "jupyter notebook";
        pnb = "julia -e 'import Pluto; Pluto.run()'";
        pip = "python3 -m pip";
        pup = "python3 -m pip install --upgrade pip";
        pmhttp = "python3 -m http.server";
        clippy = "cat ${homedir}/.cargo/clippy.conf | xargs cargo clippy --all-features --";

        clip = "xclip -selection c";

        youtube-dl-s = "youtube-dl --config-location ~/.config/youtube-dl/soundtracks.conf";
        youtube-dl-a = "youtube-dl --config-location ~/.config/youtube-dl/albums.conf";

        rclone = "rclone --progress --bwlimit=\"09:00,256 23:00,off\"";

        resetwifi = "nmcli networking off && nmcli networking on";

        gp = "git push";
        gpfwl = "git push --force-with-lease";
        gpx = "git push && exit";
        gst = "git status";
        ga = "git add -A";
        gf = "git fetch";
        gpl = "git pull";
        gfpl = "git fetch && git pull";
        gl = "git log";

        gstall = "python ~/repos/git_all.py status";
        gfall = "python ~/repos/git_all.py fetch";
        gplall = "python ~/repos/git_all.py pull";
        gfplall = "python ~/repos/git_all.py fetch && python ~/repos/git_all.py pull";
        gpall = "python ~/repos/git_all.py push";

        # Search long-form history
        grephist = "cat ~/.bash_history | grep --";
      };
      bashrcExtra = ''
        trySource() {
            if [ -f "$1" ]; then
                . "$1"
            fi
        }

        trySource "${homedir}/.cargo/env"

        bind -s 'set completion-ignore-case on'

        buildPrompt() {
            local exit_code="$?" # We need this first to catch it

            history -a

            local force_color_prompt=yes
            local color_prompt=

            PS1=""

            if [ -n "$force_color_prompt" ]; then
                if which tput &>/dev/null && tput setaf 1 >&/dev/null; then
                    color_prompt=yes
                else
                    color_prompt=
                fi
            else
              color_prompt=yes
            fi

            if [ "$color_prompt" = yes ]; then
                PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]'
            else
                PS1='\u@\h:\w'
            fi

            if [ $EXTENDED_PS1 -ne 0 ]; then
                if [ ! -f "${homedir}/.git-prompt.sh" ]; then
                    echo "${homedir}/.git-prompt.sh not found!"
                fi

                # Add git information and $ to prompt
                GIT_PS1_SHOWDIRTYSTATE=true
                GIT_PS1_SHOWSTASHSTATE=true
                GIT_PS1_SHOWUNTRACKEDFILES=true
                GIT_PS1_SHOWUPSTREAM="auto"
                GIT_PS1_HIDE_IF_PWD_IGNORED=true

                trySource "${homedir}/.git-prompt.sh"

                if [ "$color_prompt" = yes ]; then
                    PS1="$PS1\[\033[01;31m\]$(__git_ps1 " [%s]")\[\033[00m\]"
                else
                    PS1="$PS1$(__git_ps1 " [%s]")"
                fi
            fi

            if [ -n "$VIRTUAL_ENV" ] && [ $EXTENDED_PS1 -ne 0 ]; then
                # If there is a venv, we only want the penultimate dir in the path, so we grep it
                venv=$(echo $VIRTUAL_ENV | grep -Po "[^/]*(?=/[^/]*$)")
                # We then disable the normal venv prompt addition
                VIRTUAL_ENV_DISABLE_PROMPT=1

                # We then add the venv to the start of the PS1, in a nice cyan colour if possible
                if [ "$color_prompt" = yes ]; then
                    PS1="\[\033[01;36m\]($venv)\[\033[00m\] $PS1"
                else
                    PS1="($venv) $PS1"
                fi
            fi

            # If we're in a nix-shell, then add that to the start in pink
            if ([ -n "$IN_NIX_SHELL" ] || [ -n "$NIX_GCROOT" ]) && [ $EXTENDED_PS1 -ne 0 ]; then
                if [ "$color_prompt" = yes ]; then
                    PS1="\[\033[01;38;5;206m\][nix-shell]\[\033[00m\] $PS1"
                else
                    PS1="[nix-shell] $PS1"
                fi
            fi

            if [ $exit_code -ne 0 ] && [ $EXTENDED_PS1 -ne 0 ]; then
                if [ "$color_prompt" = yes ]; then
                    PS1="\[\033[01;31m\]$exit_code\[\033[00m\] $PS1"
                else
                    PS1="$exit_code $PS1"
                fi
            fi

            if [ "$color_prompt" = yes ]; then
                PS1="$PS1\n\[\033[01;32m\]\$\[\033[00m\] "
            else
                PS1="$PS1\n\$ "
            fi
        }
        export PROMPT_COMMAND=buildPrompt

        # This is a function because if it's an alias, the curl command gets
        # evaluated when the file is sourced rather than when the alias is run
        # We run it through echo to get a newline at the end
        myip() {
            echo $(curl --silent ipinfo.io/ip)
        }

        # Taken from https://unix.stackexchange.com/a/391698/459068
        _insert_text_into_terminal() {
            perl -le 'require "sys/ioctl.ph";
                    $delay = 0.05;
                    unless(fork) {
                        select undef, undef, undef, $delay;
                        ioctl(STDIN, &TIOCSTI, $_) for split "", join " ", @ARGV;
                    }' -- "$@";
        }

        # Fuzzy find in bash history
        fzh() {
            local command="$(cat ${homedir}/.bash_history | fzf --tac | awk '{$1=$1};1')"
            if [ "$command" = "" ]; then
                return
            else
                _insert_text_into_terminal "$command "
            fi
        }

        # Copy Unicode code point
        cpunicp() {
            string="\\u$1"
            python -c "print('$string', end=\"\")" | xclip -selection c
        }

        # Create executable file and open it with vim
        vex() {
            ${my-nixvim}/bin/nvim "$1"
            if [ -f "$1" ]; then
                chmod +x "$1"
            fi
        }

        # Easily copy a file
        cclip() {
            cat "$1" | clip
        }

        clipo() {
            echo "$(clip -o)"
        }

        # Decode base 64
        b64d() {
            echo "$1" | base64 -d
        }

        # Make a directory without complaining that it already exists
        mkd() {
            if [ ! -d "$1" ]; then
                mkdir -p -- "$1"
            fi
        }

        # Make a directory and cd into it
        mkcd () {
            mkd "$1"
            cd -- "$1"
        }

        # Make a directory and push it onto to the stack
        mkpushd() {
            mkd "$1"
            pushd -- "$1"
        }
      '';
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
        key = "F1C0D1EBB627CF58";
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
        init.defaultBranch = "main";
        pull = {
          rebase = false;
          ff = "only";
        };
        push = {
          followTags = true;
          autoSetupRemote = true;
          default = "current";
        };
        fetch.prune = true;
        merge.ff = false;
      };
    };
  };
}
