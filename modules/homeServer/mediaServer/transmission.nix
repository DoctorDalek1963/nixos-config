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
        proxyPass = "http://localhost:${toString cfg.ports.mediaServer.transmission}";
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
    '';

    # These service configs were mostly taken from
    # https://mth.st/blog/nixos-wireguard-netns/
    # The idea is to create a separate network namespace to run transmission
    # inside of, so transmission gets all its traffic routed through a VPN, but
    # the rest of the system has its traffic routed normally.
    systemd.services = {
      "netns@" = {
        description = "%I network namespace";
        before = ["network.target"];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          PrivateNetwork = true;
          ExecStart = "${pkgs.writeShellScript "netns-up" ''
            ${pkgs.iproute2}/bin/ip netns add $1
            ${pkgs.utillinux}/bin/umount /var/run/netns/$1
            ${pkgs.utillinux}/bin/mount --bind /proc/self/ns/net /var/run/netns/$1
          ''} %I";
          ExecStop = "${pkgs.iproute2}/bin/ip netns del %I";
          # This is required since systemd commit c2da3bf, shipped in systemd 254.
          # See discussion at https://github.com/systemd/systemd/issues/28686
          PrivateMounts = false;
        };
      };

      transmissionVpn = {
        description = "transmissionVpn network interface";
        bindsTo = ["netns@transmissionVpn.service"];
        requires = ["network-online.target" "nss-lookup.target"];
        after = ["netns@transmissionVpn.service" "network-online.target" "nss-lookup.target"];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = let
            ip = "${pkgs.iproute2}/bin/ip";
          in
            pkgs.writeShellScript "transmissionVpn-up" ''
              ${ip} link add transmissionVpn type veth
              ${pkgs.openvpn}/bin/openvpn --daemon openvpn-transmissionVpn --config ${cfgMs.transmissionOvpn}
              ${ip} link set transmissionVpn netns transmissionVpn up

              ${ip} -n transmissionVpn address add 0.0.0.0 dev transmissionVpn
              ${ip} -n transmissionVpn -6 address add :: dev transmissionVpn
              ${ip} -n transmissionVpn route add default dev transmissionVpn
              ${ip} -n transmissionVpn -6 route add default dev transmissionVpn
            '';

          ExecStop = let
            ip = "${pkgs.iproute2}/bin/ip";
          in
            pkgs.writeShellScript "transmissionVpn-down" ''
              ${ip} -n transmissionVpn link del transmissionVpn
              ${ip} -n transmissionVpn route del default dev transmissionVpn
            '';
          #   ${pkgs.iproute}/bin/ip link add wg type wireguard
          #   ${pkgs.wireguard}/bin/wg set wg \
          #     private-key ${cfg.privateKey} \
          #     peer ${cfg.peer} \
          #     allowed-ips 0.0.0.0/0,::/0 \
          #     endpoint ${cfg.endpoint}
          #   ${pkgs.iproute}/bin/ip link set wg netns wg up
          #   ${pkgs.iproute}/bin/ip -n wg address add ${cfg.address.IPv4} dev wg
          #   ${pkgs.iproute}/bin/ip -n wg -6 address add ${cfg.address.IPv6} dev wg
          #   ${pkgs.iproute}/bin/ip -n wg route add default dev wg
          #   ${pkgs.iproute}/bin/ip -n wg -6 route add default dev wg
          # '';
          # ExecStop = pkgs.writers.writeDash "transmissionVpn-down" ''
          #   ${pkgs.iproute}/bin/ip -n wg link del wg
          #   ${pkgs.iproute}/bin/ip -n wg route del default dev wg
          # '';
        };
      };

      transmission = {
        bindsTo = ["transmissionVpn.service"];
        after = ["transmissionVpn.service"];
        unitConfig.JoinsNamespaceOf = "netns@transmissionVpn.service";
        serviceConfig = {
          ExecStartPre = [
            "${pkgs.iproute}/bin/ip addr"
            "${pkgs.curl}/bin/curl icanhazip.com"
          ];
          PrivateNetwork = true;
        };
      };
    };
  };
}
