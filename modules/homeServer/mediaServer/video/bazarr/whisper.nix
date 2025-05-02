{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  cacheDir = "/var/cache/whisper-asr";
  cacheDirPerms = {
    user = "bazarr";
    group = "media";
    mode = "755";
  };
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable && (cfgMs.movies || cfgMs.telly)) {
    setup.impermanence.keepDirs = [
      ({directory = cacheDir;} // cacheDirPerms)
    ];

    systemd.tmpfiles.settings.whisperAsr."${cacheDir}".d = cacheDirPerms;

    # I really don't want to use an OCI container here but packaging the
    # underlying Python app was a massive headache, and the docker image is
    # provided and maintained
    virtualisation.oci-containers.containers.whisper-asr-webservice = {
      image = "onerahmet/openai-whisper-asr-webservice:v1.8.2-gpu";
      # pull = "never"; # TODO (25.05): Uncomment this
      imageFile = pkgs.dockerTools.pullImage {
        imageName = "onerahmet/openai-whisper-asr-webservice";
        finalImageTag = "v1.8.2-gpu";
        imageDigest = "sha256:75f21f1fffdb69f40f9f1dccfeb9f581c14242b4b43c5437e0910c94f2bb51d4";
        sha256 = "1l386gj5jls0hwfs40hpyhzd0hb3qv690sl08c9hbbv5l341mb6j";
      };

      user = "bazarr:media";
      ports = ["127.0.0.1:${toString cfg.ports.mediaServer.whisper-asr}:9000"];
      volumes = ["${cacheDir}:/root/.cache"];

      environment = {
        ASR_MODEL = "base";
        ASR_ENGINE = "openai_whisper";
      };

      extraOptions = ["--gpus=all"];
    };
  };
}
