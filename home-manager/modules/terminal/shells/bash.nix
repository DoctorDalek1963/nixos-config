{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (config.consts) nvimPath;
in
{
  config = lib.mkIf config.setup.terminal.shells.bash {
    setup.impermanence = {
      keepFiles = [ ".bash_history" ];
      keepDirs = [
        ".cache/blesh/${
          let
            list = lib.strings.split "\\." pkgs.blesh.version;
            major = builtins.elemAt list 0;
            minor = builtins.elemAt list 2;
          in
          "${major}.${minor}"
        }"
      ];
    };

    home = {
      file.".blerc".text =
        # bash
        ''
          bleopt editor=${nvimPath}

          # I put any non-zero exit code in my PS1, so I don't need it from ble as well
          bleopt exec_errexit_mark=

          bleopt history_lazyload=1

          bleopt indent_offset=4
          bleopt indent_tabs=0

          bleopt edit_line_type=graphical

          ble-face argument_error=fg=black,bg=white
          ble-face argument_option=fg=cyan
          ble-face auto_complete=fg=black,bg=magenta
          ble-face cmdinfo_cd_cdpath=fg=lime,bold
          ble-face command_alias=fg=cyan
          ble-face command_builtin=fg=red
          ble-face command_builtin_dot=fg=red,bold
          ble-face command_directory=fg=navy,underline
          ble-face command_file=fg=green
          ble-face command_function=fg=purple
          ble-face command_jobs=fg=red,bold
          ble-face command_keyword=fg=blue
          ble-face disabled=fg=gray
          ble-face filename_block=fg=yellow,bg=black,underline
          ble-face filename_character=fg=white,bg=black,underline
          ble-face filename_directory=fg=navy,underline
          ble-face filename_directory_sticky=fg=black,bg=navy,underline
          ble-face filename_executable=fg=green,underline
          ble-face filename_link=fg=cyan,underline
          ble-face filename_ls_colors=underline
          ble-face filename_orphan=fg=black,bg=yellow,underline
          ble-face filename_other=underline
          ble-face filename_pipe=fg=lime,bg=black,underline
          ble-face filename_setgid=fg=black,bg=lime,underline
          ble-face filename_setuid=fg=black,bg=yellow,underline
          ble-face filename_socket=fg=cyan,bg=black,underline
          ble-face filename_url=fg=blue,underline
          ble-face filename_warning=fg=red,underline
          ble-face overwrite_mode=fg=black,bg=navy
          ble-face prompt_status_line=fg=white,bg=gray
          ble-face region=fg=black,bg=silver
          ble-face region_insert=fg=black,bg=white
          ble-face region_match=fg=gray,bg=purple
          ble-face region_target=fg=black,bg=teal
          ble-face syntax_brace=fg=cyan,bold
          ble-face syntax_command=fg=brown
          ble-face syntax_comment=fg=gray
          ble-face syntax_default=none
          ble-face syntax_delimiter=bold
          ble-face syntax_document=fg=brown
          ble-face syntax_document_begin=fg=brown,bold
          ble-face syntax_error=fg=black,bold,bg=orange
          ble-face syntax_escape=fg=magenta
          ble-face syntax_expr=fg=navy
          ble-face syntax_function_name=fg=purple,bold
          ble-face syntax_glob=fg=magenta,bold
          ble-face syntax_history_expansion=fg=black,bg=orange
          ble-face syntax_param_expansion=fg=purple
          ble-face syntax_quotation=fg=green,bold
          ble-face syntax_quoted=fg=green
          ble-face syntax_tilde=fg=navy,bold
          ble-face syntax_varname=fg=orange
          ble-face varname_array=fg=orange,bold
          ble-face varname_empty=fg=navy
          ble-face varname_export=fg=magenta,bold
          ble-face varname_expr=fg=purple,bold
          ble-face varname_hash=fg=green,bold
          ble-face varname_number=fg=green
          ble-face varname_readonly=fg=purple
          ble-face varname_transform=fg=teal,bold
          ble-face varname_unset=fg=red
          ble-face vbell=reverse
          ble-face vbell_erase=fg=yellow,reverse
          ble-face vbell_flash=fg=green,reverse
        '';
    };

    programs.bash = {
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

      inherit (config.setup.terminal) shellAliases;

      bashrcExtra = ''
        # Use ble.sh for syntax highlighting and other improvements to the line editor
        [[ $- == *i* ]] && source ${pkgs.blesh}/share/blesh/ble.sh

        bind -s 'set completion-ignore-case on'

        source "${pkgs.complete-alias}/bin/complete_alias"
        ${lib.strings.concatStringsSep "\n" (
          builtins.map (alias: "complete -F _complete_alias ${alias}") (
            builtins.attrNames (
              lib.filterAttrs (_name: value: !(lib.strings.hasInfix "|" value)) config.setup.terminal.shellAliases
            )
          )
        )}

        # Automatically attach to a running Zellij session, but only when
        # connecting over SSH
        if [ -n "$SSH_CLIENT" ]; then
            export ZELLIJ_AUTO_ATTACH=true
        fi

        # An easily grepable ps
        psg() {
          if [ "$1" != "" ]; then
            procs=$(${pkgs.procps}/bin/ps auxf)
            # This just prints the first line of output - the headers of the table
            echo "$procs" | head -n 1
            # This runs ps, filters out this specific grep command, and then greps for whatever I pass as args
            echo "$procs" | ${pkgs.ripgrep}/bin/rg -v rg | ${pkgs.ripgrep}/bin/rg $@
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

        # Create executable file and open it with nvim
        vex() {
            ${nvimPath} "$1"
            if [ -f "$1" ]; then
                chmod +x "$1"
            fi
        }

        clip() {
            if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
                wl-copy
            else
                xclip -selection c
            fi
        }

        # Easily copy a file
        cclip() {
            if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
                wl-copy < "$1"
            else
                cat "$1" | xclip -selection c
            fi
        }

        # Output the clipboard
        clipo() {
            if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
                wl-paste
            else
                echo "$(xclip -selection c -o)"
            fi
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
