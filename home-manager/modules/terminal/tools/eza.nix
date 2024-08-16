{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkMerge [
    (lib.mkIf config.setup.terminal.tools.eza {
      home.packages = [pkgs.eza];

      setup.terminal.shellAliases = {
        ls = "${pkgs.eza}/bin/eza";
        ll = "${pkgs.eza}/bin/eza --long --all --mounts --icons=auto --group --header --git";
      };
    })
    (lib.mkIf (!config.setup.terminal.tools.eza) {
      setup.terminal.shellAliases = {
        ls = "ls --color=auto";
        ll = "ls -la";
        la = "ls -a";
        lh = "ls -lah";
      };
    })
  ];
}
