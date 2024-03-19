{
  config,
  inputs,
  ...
}: {
  programs.git = {
    enable = config.setup.terminalTools.git;
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
      enable = config.setup.terminalTools.delta;
      options = {
        navigate = true;
        light = false;
        syntax-theme = "OneHalfDark";
        line-numbers = true;
      };
    };
    extraConfig =
      {
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
      }
      // (
        if config.setup.terminalTools.nvim
        then {core.editor = "${inputs.my-nixvim}/bin/nvim";}
        else {}
      );
  };
}
