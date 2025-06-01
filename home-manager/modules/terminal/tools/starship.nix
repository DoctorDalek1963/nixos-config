{
  lib,
  config,
  ...
}: let
  concatVars = vars: lib.concatMapStringsSep "" (x: "\$${x}") vars;
in {
  programs.starship = {
    enable = true;
    enableBashIntegration = config.setup.terminal.shells.bash;

    settings = {
      format = concatVars [
        "status"
        "nix_shell"
        "username"
        "hostname"
        "directory"
        "git_branch"
        "git_commit"
        "git_state"
        "git_status"
        "line_break"
        "character"
      ];
      add_newline = false;

      status = {
        disabled = false;
        format = "[$status]($style) ";
        style = "bold red";
      };

      nix_shell = {
        format = ''[\[nix-shell\]]($style) '';
        style = "bold purple";
        heuristic = false;
      };

      username = {
        style_user = "bold green";
        style_root = "bold red";
        format = "[$user]($style)[@](bold)";
      };

      hostname = {
        format = "[$hostname$ssh_symbol]($style):";
        style = "bold green";
        ssh_only = true;
        ssh_symbol = "";
      };

      directory = {
        format = "[$path]($style)( [$read_only]($read_only_style)) ";
        style = "bold blue";
        read_only = "[RO]";
        read_only_style = "blue";
        truncation_length = 3;
        fish_style_pwd_dir_length = 1;
      };

      git_branch = {
        format = ''[\[$branch(:$remote_name/$remote_branch)]($style)'';
        style = "bold red";
        always_show_remote = false;
        only_attached = false;
      };

      git_commit = {
        format = " " + ''[\($hash(:$tag)\)]($style)'';
        style = "green";
        only_detached = true;
        tag_disabled = false;
        tag_symbol = "";
      };

      git_state = {
        format = " " + ''[$state( $progress_current/$progress_total)]($style)'';
        style = "yellow";
      };

      git_status = {
        format = let
          status = concatVars [
            "conflicted"
            "stashed"
            "modified"
            "deleted"
            "staged"
            "renamed"
            "typechanged"
            "untracked"
            "ahead_behind"
          ];
        in ''( [${status}]($style))[\]](bold red)'';
        style = "bold red";

        conflicted = "!";
        stashed = "\\$";
        modified = "*";
        deleted = "-";
        staged = "+";
        untracked = "%";
        renamed = "~";
        typechanged = "";

        ahead = ">";
        behind = "<";
        up_to_date = "=";
        diverged = "<>";
      };

      character = {
        success_symbol = ''[\$](bold green)'';
        error_symbol = ''[\$](bold red)'';
        vimcmd_symbol = "[V](bold green)";
        vimcmd_replace_symbol = "[V](bold purple)";
        vimcmd_replace_one_symbol = "[V](bold purple)";
        vimcmd_visual_symbol = "[V](bold yellow)";
      };
    };
  };
}
