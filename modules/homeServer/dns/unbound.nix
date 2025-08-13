{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.homeServer;
  cfgD = cfg.dns;
in
{
  config = lib.mkIf (cfg.enable && cfgD.enable) (
    lib.mkMerge [
      (lib.mkIf true {
        setup.impermanence.keepDirs = [ config.services.unbound.stateDir ];

        services.unbound = {
          enable = true;

          settings = {
            # Use unbound-control command to do things at runtime
            remote-control = {
              control-enable = true;

              control-interface = [
                "127.0.0.1"
                "::1"
              ];
              control-use-cert = false;
            };

            server = {
              port = cfg.ports.unbound;

              prefetch = true;
              num-threads = 4;

              so-reuseport = true;

              msg-cache-slabs = 4;
              rrset-cache-slabs = 4;
              infra-cache-slabs = 4;
              key-cache-slabs = 4;

              rrset-cache-size = "50m";
              msg-cache-size = "25m";

              outgoing-range = 200;
            };
          };
        };
      })

      (lib.mkIf cfgD.vpn.enable {
        # Copied from my config for transmission
        systemd.services =
          let
            ip = "${pkgs.iproute2}/bin/ip";
            openvpn-ns-service = "openvpn-ns@${cfgD.vpn.ovpnName}.service";
            vpn-netns-name = "vpn-${cfgD.vpn.ovpnName}";
          in
          {
            create-unbound-veth = {
              description = "Create a pair of veth interfaces to communicate with Unbound";
              requires = [ openvpn-ns-service ];
              after = [ openvpn-ns-service ];

              serviceConfig = {
                Type = "simple";
                RestartSec = "5s";
                Restart = "on-failure";

                ExecStart = pkgs.writeShellScript "create-unbound-veth" ''
                  ${ip} link add veth1unbnd type veth peer veth2unbnd

                  ${ip} link set veth2unbnd netns ${vpn-netns-name}

                  ${ip} addr add 192.168.${toString cfgD.vpn.thirdOctet}.1/24 dev veth1unbnd
                  ${ip} netns exec ${vpn-netns-name} ${ip} addr add 192.168.${toString cfgD.vpn.thirdOctet}.2/24 dev veth2unbnd

                  ${ip} link set veth1unbnd up
                  ${ip} netns exec ${vpn-netns-name} ${ip} link set veth2unbnd up
                  ${ip} netns exec ${vpn-netns-name} ${ip} link set lo up
                '';
              };
            };

            unbound = {
              bindsTo = [ openvpn-ns-service ];
              after = [
                openvpn-ns-service
                "create-unbound-veth.service"
                "resolvconf.service"
              ];
              requires = [
                openvpn-ns-service
                "create-unbound-veth.service"
                "resolvconf.service"
              ];

              serviceConfig = {
                ExecStartPre = [ "${pkgs.curl}/bin/curl icanhazip.com" ];

                RestartSec = "5s";
                Restart = lib.mkForce "always";

                RuntimeMaxSec = "24h";

                NetworkNamespacePath = "/run/netns/${vpn-netns-name}";
                BindReadOnlyPaths = [ "/etc/netns/${vpn-netns-name}/resolv.conf:/etc/resolv.conf" ];
              };
            };
          };
      })
    ]
  );
}
