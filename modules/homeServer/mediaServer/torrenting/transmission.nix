{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    setup = {
      impermanence.keepDirs = [config.services.transmission.home];
      backup.exclude = ["${cfgMs.mediaRoot}/torrents"];

      homeServer.mediaServer.directoryMap.transmission = [
        "${cfgMs.mediaRoot}/torrents"
        "${cfgMs.mediaRoot}/torrents/downloads"
        "${cfgMs.mediaRoot}/torrents/incomplete"
      ];
    };

    services = {
      nginx.virtualHosts."${cfg.domainName}".locations."/transmission" = {
        proxyPass =
          "http://192.168.${toString cfgMs.transmission.thirdOctet}.2"
          + ":${toString cfg.ports.mediaServer.transmission}";
      };

      transmission = {
        enable = true;
        package = pkgs.transmission_4;

        user = "transmission";
        group = "media";

        performanceNetParameters = true;

        openRPCPort = true;
        openPeerPorts = true;

        webHome = pkgs.flood-for-transmission.overrideAttrs {
          postBuild = let
            optDownloadPath = type: lib.optional cfgMs."${type}" "${cfgMs.mediaRoot}/${type}";
            optDownloadPath2 = type: folder: lib.optional cfgMs."${type}" "${cfgMs.mediaRoot}/${folder}";

            downloadPaths =
              (optDownloadPath "movies")
              ++ (optDownloadPath "telly")
              ++ (optDownloadPath "music")
              ++ (optDownloadPath2 "books" "ebooks")
              ++ (optDownloadPath2 "books" "audiobooks");

            columns = [
              ''{"label": "Percent complete", "width": 100}''
              ''{"label": "Ratio", "width": 100}''
            ];

            jqExpr = builtins.concatStringsSep " | " [
              ".WRAP_HEADER = true"
              ''.COLUMNS = .COLUMNS + [${builtins.concatStringsSep ", " columns}]''
              ".COMMON_PATH = [${builtins.concatStringsSep ", "
                (builtins.map (x: ''"${x}"'') downloadPaths)}]"
              ''.SORT_COLUMN = "Progress"''
              ''.SORT_DIRECTION = "asc"''
            ];
          in "cat public/config.json.defaults | ${pkgs.jq}/bin/jq '${jqExpr}' > public/config.json";
        };

        # See https://github.com/transmission/transmission/blob/main/docs/Editing-Configuration-Files.md#options
        settings = {
          message-level = 4; # Info

          download-dir = "${cfgMs.mediaRoot}/torrents/downloads";
          incomplete-dir = "${cfgMs.mediaRoot}/torrents/incomplete";
          downloadDirPermissions = "755";

          download-queue-enabled = false;
          seed-queue-enabled = false;

          peer-limit-global = 500;
          utp-enabled = false;

          peer-port = 64058;
          peer-port-random-on-start = false;
          port-forwarding-enabled = false;

          dht-enabled = false;
          lpd-enabled = true;
          pex-enabled = true;

          speed-limit-up = 100; # kB/s
          speed-limit-up-enabled = true;

          rpc-enabled = true;
          rpc-port = cfg.ports.mediaServer.transmission;
          rpc-url = "/transmission/";
          rpc-bind-address = "0.0.0.0";

          rpc-username = "";
          rpc-password = "admin";

          rpc-host-whitelist-enabled = false;

          rpc-whitelist-enabled = true;
          rpc-whitelist = lib.concatStringsSep "," [
            # Localhost
            "127.0.0.1"
            "::1"

            # Home network
            "192.168.*.*"

            # Tailnet
            "100.*.*.*"
          ];
        };
      };
    };

    # These service configs were mostly taken from
    # https://github.com/conallprendergast/openvpn-netns-systemd
    # The idea is to create a separate network namespace to run transmission
    # inside of, so transmission gets all its traffic routed through a VPN, but
    # the rest of the system has its traffic routed normally.
    systemd.services = let
      ip = "${pkgs.iproute2}/bin/ip";
      openvpn-ns-service = "openvpn-ns@${cfgMs.transmission.ovpnName}.service";
      vpn-netns-name = "vpn-${cfgMs.transmission.ovpnName}";
    in {
      create-transmission-veth = {
        description = "Create a pair of veth interfaces to communicate with Transmission";
        requires = [openvpn-ns-service];
        after = [openvpn-ns-service];

        serviceConfig = {
          Type = "simple";
          RestartSec = "5s";
          Restart = "on-failure";

          ExecStart = pkgs.writeShellScript "create-transmission-veth" ''
            ${ip} link add veth1transm type veth peer veth2transm

            ${ip} link set veth2transm netns ${vpn-netns-name}

            ${ip} addr add 192.168.${toString cfgMs.transmission.thirdOctet}.1/24 dev veth1transm
            ${ip} netns exec ${vpn-netns-name} ${ip} addr add 192.168.${toString cfgMs.transmission.thirdOctet}.2/24 dev veth2transm

            ${ip} link set veth1transm up
            ${ip} netns exec ${vpn-netns-name} ${ip} link set veth2transm up
            ${ip} netns exec ${vpn-netns-name} ${ip} link set lo up
          '';
        };
      };

      transmission = {
        bindsTo = [openvpn-ns-service];
        after = [openvpn-ns-service "create-transmission-veth.service" "resolvconf.service"];
        requires = [openvpn-ns-service "create-transmission-veth.service" "resolvconf.service"];

        serviceConfig = {
          ExecStartPre = ["${pkgs.curl}/bin/curl icanhazip.com"];

          RestartSec = "5s";
          Restart = "always";

          # Don't notify dependents of failure. Sometimes transmission fails a
          # couple times before succeeding, but we don't want that to stop any
          # services that depend on it
          RestartMode = "direct";

          RuntimeMaxSec = "24h";

          NetworkNamespacePath = "/run/netns/${vpn-netns-name}";
          BindReadOnlyPaths = ["/etc/netns/${vpn-netns-name}/resolv.conf:/etc/resolv.conf"];
        };
      };
    };
  };
}
