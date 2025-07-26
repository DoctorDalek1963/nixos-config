{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in
{
  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    # These service configs were mostly taken from
    # https://github.com/conallprendergast/openvpn-netns-systemd
    # The idea is to create a separate network namespace to run transmission
    # inside of, so transmission gets all its traffic routed through a VPN, but
    # the rest of the system has its traffic routed normally.
    systemd.services =
      let
        ip = "${pkgs.iproute2}/bin/ip";
      in
      {
        "netns@" = {
          description = "%i network namespace";
          before = [ "network.target" ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            PrivateNetwork = true;

            ExecStart = "${pkgs.writeShellScript "netns-up" ''
              ${ip} netns add $1
              ${ip} -n $1 addr add 127.0.0.1/8 dev lo
              ${ip} -n $1 link set dev lo up
              mkdir -p /etc/netns/$1
            ''} %i";

            ExecStop = "${pkgs.writeShellScript "" ''
              ${ip} netns del $1
              rm -rf /etc/netns/$1
            ''} %i";

            # This is required since systemd commit c2da3bf, shipped in systemd 254.
            # See discussion at https://github.com/systemd/systemd/issues/28686
            PrivateMounts = false;
          };
        };

        "openvpn-ns@" = {
          description = "OpenVPN connection to %i in new namespace";
          bindsTo = [ "netns@vpn-%i.service" ];
          requires = [
            "netns@vpn-%i.service"
            "network-online.target"
            "nss-lookup.target"
          ];
          after = [
            "netns@vpn-%i.service"
            "network-online.target"
            "nss-lookup.target"
          ];

          serviceConfig = {
            Type = "notify";
            RuntimeDirectory = "openvpn";
            CapabilityBoundingSet = lib.concatStringsSep " " [
              "CAP_IPC_LOCK"
              "CAP_NET_ADMIN"
              "CAP_NET_RAW"
              "CAP_SETGID"
              "CAP_SETUID"
              "CAP_SYS_CHROOT"
              "CAP_DAC_OVERRIDE"
              "CAP_SYS_ADMIN"
              "CAP_DAC_OVERRIDE"
              "CAP_DAC_READ_SEARCH"
            ];
            PrivateTmp = true;
            WorkingDirectory = "/etc/openvpn";
            PIDFile = "/run/openvpn/%i.pid";
            KillMode = "process";
            LimitNPROC = 10;
            DeviceAllow = [
              "/dev/null rw"
              "/dev/net/tun rw"
            ];
            ProtectSystem = true;
            ProtectHome = true;
            RestartSec = "5s";
            Restart = "on-failure";

            ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";

            ExecStart =
              let
                up-script = pkgs.writeShellScript "openvpn-ns-up" ''
                  resolv_conf_created=

                  # When called the first time, create netns-specific
                  # resolv.conf. 'ip netns exec' will bind mount this into
                  # /etc/resolv.conf inside the namespace. (note: This is
                  # compatible with NetworkManager, because it only cares about
                  # the normal namespaceless resolv.conf.)
                  create_resolv_conf () {
                      [ -n "$resolv_conf_created" ] && return
                      resolv_conf_created=true

                      # copy of $NETNS with control characters replaced with '?'
                      SAFE_NETNS="$(printf '%s' "$NETNS" | ${pkgs.coreutils}/bin/tr '\0-\37\177' '[?*]')"
                      printf '%s\n' \
                          "# Generated for openvpn connection in network namespace \"$SAFE_NETNS\"." \
                          "# This file will be automatically deleted." \
                          "# (Created as /etc/netns/$SAFE_NETNS/resolv.conf. 'ip netns exec' will" \
                          "# bind mount this into /etc/resolv.conf inside the namespace.)" \
                          "" \
                          > /etc/netns/"$NETNS"/resolv.conf
                  }

                  foreign_opt_domains=

                  # Process one OpenVPN foreign option. Called with unquoted
                  # $foreign_option_<n>.
                  process_foreign_option () {
                      case "$1:$2" in
                          dhcp-option:DNS)
                              # sanity check (IPv4 and IPv6 addresses allowed)
                              case "$3" in
                                  *[!0-9a-fA-F.:]*) return ;;
                              esac

                              create_resolv_conf
                              echo "nameserver $3" >> /etc/netns/"$NETNS"/resolv.conf
                              ;;

                          dhcp-option:DOMAIN)
                              # sanity check (valid domain names allowed)
                              case "$3" in
                                  *[!-0-9a-zA-Z.]*) return ;;
                              esac

                              create_resolv_conf
                              foreign_opt_domains="$foreign_opt_domains $3"
                              ;;
                      esac
                  }

                  # Add domains to resolv.conf. Called with unquoted
                  # $foreign_opt_domains.
                  add_domains_to_resolv_conf () {
                      if [ $# -gt 0 ]; then
                          # Not sure if multiple DOMAIN options is legal and if
                          # this is the proper way to handle them. Use first
                          # domain as our local domain and add all of them to
                          # the domain search list.
                          printf '%s\n' \
                                 "domain $1" \
                                 "search $*" \
                                 >> /etc/netns/"$NETNS"/resolv.conf
                      fi
                  }


                  # move TUN/TAP device to the network namespace
                  ${ip} link set dev "$dev" up netns "$NETNS" mtu "$tun_mtu"

                  # set device address
                  netmask4="''${ifconfig_netmask:-30}"
                  netbits6="''${ifconfig_ipv6_netbits:-112}"

                  if [ -n "$ifconfig_local" ]; then
                      if [ -n "$ifconfig_remote" ]; then
                         ${ip} netns exec "$NETNS" \
                             ${ip} -4 addr add \
                                 local "$ifconfig_local" \
                                 peer "$ifconfig_remote/$netmask4" \
                                 ''${ifconfig_broadcast:+broadcast "$ifconfig_broadcast"} \
                                 dev "$dev"
                      else
                          ${ip} netns exec "$NETNS" \
                             ${ip} -4 addr add \
                                 local "$ifconfig_local/$netmask4" \
                                 ''${ifconfig_broadcast:+broadcast "$ifconfig_broadcast"} \
                                 dev "$dev"
                      fi
                  fi
                  if [ -n "$IPV6" -a -n "$ifconfig_ipv6_local" ]; then
                      if [ -n "$ifconfig_ipv6_remote" ]; then
                          ${ip} netns exec "$NETNS" \
                             ${ip} -6 addr add \
                                local "$ifconfig_ipv6_local" \
                                peer "$ifconfig_ipv6_remote/$netbits6" \
                                dev "$dev"
                      else
                          ${ip} netns exec "$NETNS" \
                             ${ip} -6 addr add \
                                local "$ifconfig_ipv6_local/$netbits6" \
                                dev "$dev"
                      fi
                  fi

                  # if there already is a resolv.conf for our netns, don't
                  # overwrite it
                  if ! [ -e /etc/netns/"$NETNS"/resolv.conf ]; then
                      # add DNS settings if given in foreign options
                      i=1
                      while
                          eval opt=\"\$foreign_option_$i\"
                          [ -n "$opt" ]
                      do
                          process_foreign_option $opt
                          i=$(( i + 1 ))
                      done
                      add_domains_to_resolv_conf $foreign_opt_domains
                  fi
                '';

                route-up-script = pkgs.writeShellScript "openvpn-ns-route-up" ''
                  ${ip} netns exec "$NETNS" sh ${route-up-body}
                '';

                route-up-body = pkgs.writeShellScript "openvpn-ns-route-up-body" ''
                  i=1
                  while
                      eval net=\"\$route_network_$i\"
                      eval mask=\"\$route_netmask_$i\"
                      eval gw=\"\$route_gateway_$i\"
                      eval mtr=\"\$route_metric_$i\"
                      [ -n "$net" ]
                  do
                      ${ip} -4 route add "$net/$mask" via "$gw" ''${mtr:+metric "$mtr"}
                      i=$(( i + 1 ))
                  done

                  if [ -n "$route_vpn_gateway" ]; then
                      ${ip} -4 route add default via "$route_vpn_gateway"
                  fi

                  if [ -n "$IPV6" ]; then
                      i=1
                      while
                          # There doesn't seem to be $route_ipv6_metric_<n>
                          # according to the manpage.
                          eval net=\"\$route_ipv6_network_$i\"
                          eval gw=\"\$route_ipv6_gateway_$i\"
                          [ -n "$net" ]
                      do
                          ${ip} -6 route add  "$net"  via "$gw"  metric 100
                          i=$(( i + 1 ))
                      done

                      # There's no $route_vpn_gateway for IPv6. It's not
                      # documented if OpenVPN includes default route in
                      # $route_ipv6_*. Set default route to remote VPN
                      # endpoint address if there is one. Use higher metric
                      # than $route_ipv6_* routes to give preference to a
                      # possible default route in them.
                      if [ -n "$ifconfig_ipv6_remote" ]; then
                          ${ip} -6 route add  default \
                              via "$ifconfig_ipv6_remote"  metric 200
                      fi
                  fi
                '';
              in
              lib.concatStringsSep " " [
                "${pkgs.openvpn}/bin/openvpn"
                ''--setenv NETNS "vpn-%i"''
                "--up-delay"
                "--ifconfig-noexec"
                "--route-noexec"
                "--status /run/openvpn/%i.status 10"
                "--cd /etc/openvpn"
                "--script-security 2"
                ''--config "/etc/openvpn/%i.ovpn"''
                "--up ${up-script}"
                "--route-up ${route-up-script}"
              ];
          };
        };
      };
  };
}
