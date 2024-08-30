{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.terminal.tools.gh {
    programs.gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        editor = config.consts.nvimPath;
        prompt = "enabled";
        pager = "${pkgs.delta}/bin/delta";
      };
    };

    # Hello me in the future, to get GitHub logins to persist on an impermanent
    # machine, you have yo login with an extra flag:
    # `gh auth login --insecure-storage`
    setup.impermanence.keepFiles = [".config/gh/hosts.yml"];
  };
}
