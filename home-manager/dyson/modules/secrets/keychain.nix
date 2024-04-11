{
  lib,
  config,
  ...
}: let
  cfg = config.setup.secrets;
  keychain-enabled = cfg.enable && cfg.enableKeychain;
in {
  config = lib.mkIf keychain-enabled {
    programs.keychain = {
      enable = keychain-enabled;
      keys = [
        "github_main"
        "git_main_signing"
        "id_ed25519"
      ];

      enableBashIntegration = config.setup.shells.bash;
    };
  };
}
