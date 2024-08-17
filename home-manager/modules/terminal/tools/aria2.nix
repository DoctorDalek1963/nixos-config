{
  lib,
  config,
  ...
}: {
  # Taken from https://gitlab.com/LovingMelody/configsreborn/-/blob/760960bcf340a0a5773d9b764c7f58d0b050f084/modules/home/aria2/default.nix
  config = lib.mkIf config.setup.terminal.tools.aria2 {
    programs.aria2 = {
      enable = true;
      settings = {
        file-allocation = "none";
        log-level = "warn";
        max-connection-per-server = 16;
        min-split-size = "1M";
        human-readable = true;
        reuse-uri = true;
        rpc-save-upload-metadata = true;
        max-file-not-found = 0;
        remote-time = true;
        async-dns = true;
        stop = 0;
        allow-piece-length-change = true;
        optimize-concurrent-downloads = true;
        deferred-input = true;
        continue = true;
        check-integrity = true;
        realtime-chunk-checksum = true;
        piece-length = "1M";
        split = 16;
        save-session-interval = 60; # seconds
        disk-cache = "32M";
        save-not-found = true;
        download-result = "full";
        truncate-console-readout = true;
        retry-wait = 30; # seconds
        max-tries = 15;
        enable-color = true;
        enable-http-keep-alive = true;
        enable-http-pipelining = true;
        http-accept-gzip = true;
        follow-torrent = true;
        bt-save-metadata = true;
        seed-time = 0;
        bt-load-saved-metadata = true;
        metalink-preferred-protocol = "https";
      };
    };
  };
}
