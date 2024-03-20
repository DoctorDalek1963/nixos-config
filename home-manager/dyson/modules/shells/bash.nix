{
  pkgs,
  lib,
  config,
  ...
}: let
  bash-enabled = builtins.elem "bash" config.setup.shells;
  inherit (config.setup) username;
  homedir = config.home.homeDirectory;
  nvim-path = config.consts.nvim.path;
in {
  config = lib.mkIf bash-enabled {
    home = {
      packages = [pkgs.complete-alias];
      sessionVariables.EXTENDED_PS1 = 1;
    };

    programs.bash = {
      enable = bash-enabled;
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
        v = nvim-path;
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

        gstall = "git-all status";
        gfall = "git-all fetch";
        gplall = "git-all pull";
        gfplall = "git-all fetch && git-all pull";
        gpall = "git-all push";

        # Search long-form history
        rghist = "cat ~/.bash_history | rg --";
      };
      bashrcExtra = ''
        trySource() {
            if [ -f "$1" ]; then
                . "$1"
            fi
        }

        trySource "${homedir}/.cargo/env"

        bind -s 'set completion-ignore-case on'

        trySource "${pkgs.complete-alias}/bin/complete_alias"
        complete -F _complete_alias b
        complete -F _complete_alias g
        complete -F _complete_alias j
        complete -F _complete_alias p
        complete -F _complete_alias ca
        complete -F _complete_alias jl
        complete -F _complete_alias rclone

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

        # An easily grepable ps
        psg() {
          if [ "$1" != "" ]; then
            procs=$(\ps auxf)
            # This just prints the first line of output - the headers of the table
            echo "$procs" | head -n 1
            # This runs ps, filters out this specific grep command, and then greps for whatever I pass as args
            echo "$procs" | rg -v rg | rg $@
          else
            echo "Please supply something to grep for."
          fi
        }

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
            ${nvim-path} "$1"
            if [ -f "$1" ]; then
                chmod +x "$1"
            fi
        }

        # Easily copy a file
        cclip() {
            cat "$1" | xclip -selection c
        }

        clipo() {
            echo "$(xclip -selection c -o)"
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
  };
}
