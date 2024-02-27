{ config, pkgs, ... }:

let 
  homedir = "/home/dyson";
in {
  home.username = "dyson";
  home.homeDirectory = homedir;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".git-prompt.sh".source = ./files/.git-prompt.sh;
    "${homedir}/.cargo/clippy.conf".source = ./files/clippy.conf;
    "${homedir}/.config/ripgrep/config".source = ./files/ripgrep-config;
  };

  home.sessionVariables = {
    EXTENDED_PS1 = 1;
    GCC_COLORS = "error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01";
    JILL_INSTALL_DIR = "${homedir}/.local/misc/julia-versions";
    RIPGREP_CONFIG_PATH = "${homedir}/.config/ripgrep/config";
  };

  targets.genericLinux.enable = true;

  programs = {
    home-manager.enable = true;

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

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

        # Single letters
        b = "bat";
        c = "cat";
        g = "git";
        j = "just";
        p = "python";
        t = "touch";
        v = "nvim";
        x = "exit";

        # Two letters
        ca = "cargo";
        cl = "clear";
        jl = "julia";
        ps = "ps auxf";
        rm = "rm -v";
        rs = "evcxr";

        ipy = "python -m IPython";
        jnb = "jupyter notebook";
        pnb = "julia -e 'import Pluto; Pluto.run()'";
        pip = "python -m pip";
        pup = "python -m pip install --upgrade pip";
        pmhttp = "python -m http.server";
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
        source ${homedir}/.profile

        if [ -f "${homedir}/.nix-profile/etc/profile.d/nix.sh" ]; then
            source "${homedir}/.nix-profile/etc/profile.d/nix.sh"
        fi

        bind -s 'set completion-ignore-case on'

        buildPrompt() {
            local exit_code="$?" # We need this first to catch it

            history -a

            local force_color_prompt=yes
            local color_prompt=

            PS1=""

            if [ -n "$force_color_prompt" ]; then
                if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
                    color_prompt=yes
                else
                    color_prompt=
                fi
            fi

            if [ "$color_prompt" = yes ]; then
                PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]'
            else
                PS1='\u@\h:\w'
            fi

            if [ $EXTENDED_PS1 -ne 0 ]; then
                if [ ! -f ${homedir}/.git-prompt.sh ]; then
                    echo "${homedir}/.git-prompt.sh not found!"
                fi

                # Add git information and $ to prompt
                GIT_PS1_SHOWDIRTYSTATE=true
                GIT_PS1_SHOWSTASHSTATE=true
                GIT_PS1_SHOWUNTRACKEDFILES=true
                GIT_PS1_SHOWUPSTREAM="auto"
                GIT_PS1_HIDE_IF_PWD_IGNORED=true

                source ${homedir}/.git-prompt.sh

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
            vim "$1"
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
        core.editor = "${pkgs.neovim}/bin/nvim";
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
