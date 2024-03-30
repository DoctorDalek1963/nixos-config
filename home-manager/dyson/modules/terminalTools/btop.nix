{
  pkgs,
  config,
  ...
}: let
  cfg = config.setup.terminalTools.btop;
  package =
    if cfg.gpuSupport
    then
      pkgs.unstable.btop.override {
        cudaSupport = true;
        rocmSupport = true;
      }
    else pkgs.btop;
in {
  programs.btop = {
    inherit (cfg) enable;
    inherit package;
    settings = {
      theme = "onedark";
      theme_background = false;
      update_ms = 500;
      proc_tree = true;
    };
  };
}
