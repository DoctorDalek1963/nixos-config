{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.terminal.tools.git {
    programs.git = {
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
        key = "${config.home.homeDirectory}/.ssh/git_main_signing";
        signByDefault = true;
      };
      delta = {
        enable = config.setup.terminal.tools.delta;
        options = {
          navigate = true;
          light = false;
          syntax-theme =
            {
              onedark = "OneHalfDark";
              catppuccin-macchiato = "catppuccin-macchiato";
            }
            .${config.setup.terminal.theme};
          line-numbers = true;
        };
      };
      extraConfig = {
        core.editor = config.consts.nvimPath;
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

    setup.terminal.shellAliases = {
      g = "git";
      gp = "git push";
      gpfwl = "git push --force-with-lease";
      gpx = "git push && exit";
      gst = "git status";
      ga = "git add -A";
      gf = "git fetch";
      gpl = "git pull";
      # gfpl = "git fetch && git pull";
      gflg = "git fetch && git lg";
    };
  };
}
