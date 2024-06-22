{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  dir = "/etc/private-tracker-bookkeeping";

  openvpn-ns-service = "openvpn-ns@${cfgMs.transmission.ovpnName}.service";
  vpn-netns-name = "vpn-${cfgMs.transmission.ovpnName}";

  mkService = {
    name,
    description,
    script,
  }: {
    "${name}" = {
      inherit description;

      bindsTo = [openvpn-ns-service];
      after = [openvpn-ns-service "create-transmission-veth.service"];
      requires = [openvpn-ns-service "create-transmission-veth.service"];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript name script}";

        NetworkNamespacePath = "/run/netns/${vpn-netns-name}";
        BindReadOnlyPaths = ["/etc/netns/${vpn-netns-name}/resolv.conf:/etc/resolv.conf"];
      };
    };
  };

  mkTimer = serviceName: OnCalendar: {
    "${serviceName}" = {
      wantedBy = ["timers.target"];
      partOf = ["${serviceName}.service"];
      timerConfig = {
        inherit OnCalendar;
        Unit = "${serviceName}.service";
      };
    };
  };
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    boot.postBootCommands = "mkdir -p ${dir}";

    systemd = {
      services = mkService {
        name = "mam-dynamic-ip";
        description = "Handle dynamic VPN IPs for MAM";
        script = ''
          ${pkgs.curl}/bin/curl -v -c ${dir}/mam.cookies -b ${dir}/mam.cookies \
            https://t.myanonamouse.net/json/dynamicSeedbox.php
        '';
      };

      timers = mkTimer "mam-dynamic-ip" "0/2:00:00";
    };
  };
}
