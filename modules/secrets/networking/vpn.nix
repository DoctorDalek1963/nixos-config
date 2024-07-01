{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.secrets.vpn;

  optSet = cond: set:
    if cond
    then set
    else {};

  vpnEnabled = name: builtins.elem name (map ({vpnName, ...}: vpnName) cfg.vpns);

  bash-script = let
    nmcli = "${pkgs.networkmanager}/bin/nmcli";
    nmcli-command-blocks = map ({
      vpnName,
      users,
    }: let
      perm-commands =
        map
        (username: "${nmcli} connection modify ${vpnName} +connection.permissions '${username}'")
        users;
    in
      # bash
      ''
        ${nmcli} connection delete ${vpnName} || true
        ${nmcli} connection import type openvpn file "/etc/openvpn/${vpnName}.ovpn"

        ${nmcli} connection modify ${vpnName} connection.permissions ""
        ${lib.concatStringsSep "\n" perm-commands}

        ${nmcli} connection modify ${vpnName} vpn.user-name "$(head -1 ${config.sops.secrets."openvpn/${vpnName}/user-pass".path})"
        ${nmcli} connection modify ${vpnName} -vpn.data "password-flags=1"
        ${nmcli} connection modify ${vpnName} +vpn.data "password-flags=0"
        ${nmcli} connection modify ${vpnName} vpn.secrets "password=$(head -2 ${config.sops.secrets."openvpn/${vpnName}/user-pass".path} | tail -1)"
      '')
    cfg.vpns;
  in
    pkgs.writeShellScriptBin "import-ovpn-files" (lib.concatStringsSep "\n\n\n" nmcli-command-blocks);
in {
  config = lib.mkIf config.setup.secrets.vpn.enable {
    environment.systemPackages = [pkgs.openvpn];

    sops.secrets =
      {}
      // optSet (vpnEnabled "ch-hotspotshield") {
        "openvpn/ch-hotspotshield/user-pass" = {
          mode = "0644";
        };
        "openvpn/ch-hotspotshield/cert" = {
          mode = "0644";
        };
        "openvpn/ch-hotspotshield/key" = {
          mode = "0644";
        };
        "openvpn/ch-hotspotshield/ca" = {
          mode = "0644";
        };
      }
      // optSet (vpnEnabled "gb-hotspotshield") {
        "openvpn/gb-hotspotshield/user-pass" = {
          mode = "0644";
        };
        "openvpn/gb-hotspotshield/cert" = {
          mode = "0644";
        };
        "openvpn/gb-hotspotshield/key" = {
          mode = "0644";
        };
        "openvpn/gb-hotspotshield/ca" = {
          mode = "0644";
        };
      }
      // optSet (vpnEnabled "us-hotspotshield") {
        "openvpn/us-hotspotshield/user-pass" = {
          mode = "0644";
        };
        "openvpn/us-hotspotshield/cert" = {
          mode = "0644";
        };
        "openvpn/us-hotspotshield/key" = {
          mode = "0644";
        };
        "openvpn/us-hotspotshield/ca" = {
          mode = "0644";
        };
      };

    networking.networkmanager.plugins = [pkgs.networkmanager-openvpn];

    # To generate .ovpn files for other locations, follow the guidance on
    # https://support.hotspotshield.com/hc/en-us/articles/360046865972-How-do-I-install-Hotspot-Shield-on-OpenVPN-devices
    environment.etc = let
      build-hss-ovpn = country: remote: {
        "openvpn/${country}-hotspotshield.ovpn".text = ''
          client
          dev tun
          proto udp
          remote ${remote} 8041
          verify-x509-name ${remote} name
          resolv-retry infinite
          remote-random
          nobind
          tun-mtu 1500
          tun-mtu-extra 32
          mssfix 1450
          persist-key
          persist-tun
          ping 15
          ping-restart 0
          reneg-sec 0
          remote-cert-tls server
          comp-noadapt
          auth-user-pass ${config.sops.secrets."openvpn/${country}-hotspotshield/user-pass".path}
          auth sha256
          cipher AES-128-CBC
          verb 3

          cert ${config.sops.secrets."openvpn/${country}-hotspotshield/cert".path}
          key ${config.sops.secrets."openvpn/${country}-hotspotshield/key".path}
          ca ${config.sops.secrets."openvpn/${country}-hotspotshield/ca".path}
        '';
      };
    in
      optSet (vpnEnabled "ch-hotspotshield") (build-hss-ovpn "ch" "metal-band.us")
      // optSet (vpnEnabled "gb-hotspotshield") (build-hss-ovpn "gb" "penfactory.us")
      // optSet (vpnEnabled "us-hotspotshield") (build-hss-ovpn "us" "universitycalendar.us");

    systemd.services.networkmanager-import-ovpn-files = {
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "3s";
        ExecStart = "${bash-script}/bin/import-ovpn-files";
      };
      wantedBy = ["network-online.target"];
    };
  };
}
