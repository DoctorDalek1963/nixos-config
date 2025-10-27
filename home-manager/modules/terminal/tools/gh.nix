{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.setup.terminal.tools.gh {
    programs.gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        editor = config.setup.shared.nvim.path;
        prompt = "enabled";
        pager = lib.getExe config.programs.delta.package;
      };
    };

    # Hello me in the future, to get GitHub logins to persist on an impermanent
    # machine, you have to login with an extra flag:
    # `gh auth login --insecure-storage`
    setup.impermanence.keepFiles = [ ".config/gh/hosts.yml" ];
  };
}
