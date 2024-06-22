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
    services = {
      nginx.virtualHosts."${cfg.domainName}".locations."/transmission" = {
        proxyPass = "http://192.168.${toString cfgMs.transmission.thirdOctet}.2:${toString cfg.ports.mediaServer.transmission}";
      };

      transmission = {
        enable = true;
        user = "transmission";
        group = "media";

        # performanceNetParameters = true;

        openRPCPort = true;
        openPeerPorts = true;

        webHome = pkgs.flood-for-transmission;

        settings = {
          download-dir = "${cfgMs.mediaRoot}/torrents/downloads";
          incomplete-dir = "${cfgMs.mediaRoot}/torrents/incomplete";
          downloadDirPermissions = "755";

          # peer-limit-global = 500;

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

    boot.postBootCommands = ''
      mkdir -p ${cfgMs.mediaRoot}/torrents/downloads
      mkdir -p ${cfgMs.mediaRoot}/torrents/incomplete
      chown -R transmission:media ${cfgMs.mediaRoot}/torrents
      chmod -R a+r ${cfgMs.mediaRoot}/torrents
    '';

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
        after = [openvpn-ns-service "create-transmission-veth.service"];
        requires = [openvpn-ns-service "create-transmission-veth.service"];
        serviceConfig = {
          ExecStartPre = ["${pkgs.curl}/bin/curl icanhazip.com"];
          RestartSec = "5s";
          Restart = "on-failure";

          NetworkNamespacePath = "/run/netns/${vpn-netns-name}";
          BindReadOnlyPaths = ["/etc/netns/${vpn-netns-name}/resolv.conf:/etc/resolv.conf"];
        };
      };
    };
  };
}
