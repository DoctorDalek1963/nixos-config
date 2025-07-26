{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in
{
  imports = [ inputs.whisper-asr-webservice-flake.nixosModules.default ];

  config = lib.mkIf (cfg.enable && cfgMs.enable && (cfgMs.movies || cfgMs.telly)) {
    setup.impermanence.keepDirs = [
      {
        directory = config.services.whisper-asr.dataDir;
        inherit (config.services.whisper-asr) user;
        group = "media";
        mode = "750";
      }
    ];

    services.whisper-asr = {
      enable = true;
      autoStart = false;
      group = "media";
    };

    systemd.services.whisper-asr.environment = {
      ASR_MODEL = "small";
      # ASR_ENGINE = "faster_whisper"; # Needs old, incompatible CUDA libraries
    };
  };
}
