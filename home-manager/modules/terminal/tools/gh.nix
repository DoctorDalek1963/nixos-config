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
  };
}
