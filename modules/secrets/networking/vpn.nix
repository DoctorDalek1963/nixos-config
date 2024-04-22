{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.secrets.vpn.enable {
    environment.systemPackages = [pkgs.openvpn];

    sops.secrets = {
      "openvpn/hotspotshield-gb/user-pass" = {
        mode = "0644";
      };
      "openvpn/hotspotshield-gb/cert" = {
        mode = "0644";
      };
      "openvpn/hotspotshield-gb/key" = {
        mode = "0644";
      };
      "openvpn/hotspotshield-gb/ca" = {
        mode = "0644";
      };
    };

    networking.networkmanager.plugins = [pkgs.networkmanager-openvpn];

    # To generate .ovpn files for other locations, follow the guidance on
    # https://support.hotspotshield.com/hc/en-us/articles/360046865972-How-do-I-install-Hotspot-Shield-on-OpenVPN-devices
    environment.etc."openvpn/hotspotshield-gb.ovpn".text = ''
      client
      dev tun
      proto udp
      remote penfactory.us 8041
      verify-x509-name penfactory.us name
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
      auth-user-pass ${config.sops.secrets."openvpn/hotspotshield-gb/user-pass".path}
      auth sha256
      cipher AES-128-CBC
      verb 3

      cert ${config.sops.secrets."openvpn/hotspotshield-gb/cert".path}
      key ${config.sops.secrets."openvpn/hotspotshield-gb/key".path}
      ca ${config.sops.secrets."openvpn/hotspotshield-gb/ca".path}
    '';
  };
}
