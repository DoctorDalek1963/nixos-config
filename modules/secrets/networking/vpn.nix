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

      add-credentials =
        if lib.hasSuffix "hotspotshield" vpnName
        then
          # bash
          ''
            ${nmcli} connection modify ${vpnName} vpn.user-name "$(head -1 ${config.sops.secrets."openvpn/${vpnName}/user-pass".path})"
            ${nmcli} connection modify ${vpnName} -vpn.data "password-flags=1"
            ${nmcli} connection modify ${vpnName} +vpn.data "password-flags=0"
            ${nmcli} connection modify ${vpnName} vpn.secrets "password=$(head -2 ${config.sops.secrets."openvpn/${vpnName}/user-pass".path} | tail -1)"
          ''
        else "";
    in
      # bash
      ''
        ${nmcli} connection delete ${vpnName} || true
        ${nmcli} connection import type openvpn file "/etc/openvpn/${vpnName}.ovpn"

        ${nmcli} connection modify ${vpnName} connection.permissions ""
        ${lib.concatStringsSep "\n" perm-commands}

        ${add-credentials}
      '')
    cfg.vpns;
  in
    pkgs.writeShellScriptBin "import-ovpn-files" (lib.concatStringsSep "\n\n\n" nmcli-command-blocks);
in {
  config = lib.mkIf config.setup.secrets.vpn.enable {
    environment.systemPackages = [pkgs.openvpn];

    sops.secrets =
      {}
      // optSet (vpnEnabled "ch_airvpn") {
        "openvpn/ch_airvpn/ca" = {
          mode = "0644";
        };
        "openvpn/ch_airvpn/cert" = {
          mode = "0644";
        };
        "openvpn/ch_airvpn/key" = {
          mode = "0644";
        };
        "openvpn/ch_airvpn/tls-crypt" = {
          mode = "0644";
        };
      }
      // optSet (vpnEnabled "ch_hotspotshield") {
        "openvpn/ch_hotspotshield/user-pass" = {
          mode = "0644";
        };
        "openvpn/ch_hotspotshield/cert" = {
          mode = "0644";
        };
        "openvpn/ch_hotspotshield/key" = {
          mode = "0644";
        };
        "openvpn/ch_hotspotshield/ca" = {
          mode = "0644";
        };
      }
      // optSet (vpnEnabled "gb_hotspotshield") {
        "openvpn/gb_hotspotshield/user-pass" = {
          mode = "0644";
        };
        "openvpn/gb_hotspotshield/cert" = {
          mode = "0644";
        };
        "openvpn/gb_hotspotshield/key" = {
          mode = "0644";
        };
        "openvpn/gb_hotspotshield/ca" = {
          mode = "0644";
        };
      };

    networking.networkmanager.plugins = [pkgs.networkmanager-openvpn];

    # To generate .ovpn files for other locations, follow the guidance on
    # https://support.hotspotshield.com/hc/en-us/articles/360046865972-How-do-I-install-Hotspot-Shield-on-OpenVPN-devices
    environment.etc = let
      build-airvpn-ovpn = country: {
        "openvpn/${country}_airvpn.ovpn".text = ''
          client
          dev tun
          remote ${country}3.vpn.airdns.org 443
          resolv-retry infinite
          nobind
          persist-key
          persist-tun
          auth-nocache
          verb 3
          explicit-exit-notify 5
          push-peer-info
          setenv UV_IPV6 yes
          setenv IPV6 yes
          remote-cert-tls server
          comp-lzo no
          data-ciphers AES-256-GCM:AES-256-CBC:AES-192-GCM:AES-192-CBC:AES-128-GCM:AES-128-CBC
          data-ciphers-fallback AES-256-CBC
          proto udp
          auth SHA512

          ca ${config.sops.secrets."openvpn/${country}_airvpn/ca".path}
          cert ${config.sops.secrets."openvpn/${country}_airvpn/cert".path}
          key ${config.sops.secrets."openvpn/${country}_airvpn/key".path}
          tls-crypt ${config.sops.secrets."openvpn/${country}_airvpn/tls-crypt".path}
        '';
      };

      build-hss-ovpn = country: remote: {
        "openvpn/${country}_hotspotshield.ovpn".text = ''
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
          auth-user-pass ${config.sops.secrets."openvpn/${country}_hotspotshield/user-pass".path}
          auth sha256
          cipher AES-128-CBC
          verb 3

          cert ${config.sops.secrets."openvpn/${country}_hotspotshield/cert".path}
          key ${config.sops.secrets."openvpn/${country}_hotspotshield/key".path}
          ca ${config.sops.secrets."openvpn/${country}_hotspotshield/ca".path}
        '';
      };
    in
      optSet (vpnEnabled "ch_airvpn") (build-airvpn-ovpn "ch")
      // optSet (vpnEnabled "ch_hotspotshield") (build-hss-ovpn "ch" "metal-band.us")
      // optSet (vpnEnabled "gb_hotspotshield") (build-hss-ovpn "gb" "penfactory.us");

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
