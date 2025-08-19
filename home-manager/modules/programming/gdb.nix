{ pkgs, ... }:
{
  # NOTE: Sourcing things like gdb-dashboard requires a full path like ~/.config/gdb/gdb-dashboard
  setup.impermanence.keepFiles = [ ".config/gdb/gdbinit" ];

  xdg.configFile."gdb/gdb-dashboard".source = "${pkgs.gdb-dashboard}/share/gdb-dashboard/gdbinit";
}
