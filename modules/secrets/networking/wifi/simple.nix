{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.secrets;

  bash-script = let
    nmcli = "${pkgs.networkmanager}/bin/nmcli";
    nmcli-command-blocks = map (name:
      # bash
      ''
        ${nmcli} connection delete $(get_ssid "${name}") || true
        ${nmcli} connection add type wifi con-name $(get_ssid "${name}") ifname "$wifi_device" ssid $(get_ssid "${name}")
        ${nmcli} connection modify $(get_ssid "${name}") wifi-sec.key-mgmt wpa-psk wifi-sec.psk $(get_psk "${name}")
      '')
    cfg.networking.simpleWifiNetworkNames;
    getFromEnv = type: ''
      ${pkgs.gnugrep}/bin/grep --color=never -Po "(?<=''${1}_${type}=)\S+" ${config.sops.secrets."networking/simple.env".path}
    '';
  in
    pkgs.writeShellScriptBin "add-wifi-networks-simple" ''
      wifi_device="$(${nmcli} device | ${pkgs.gawk}/bin/awk '$2 == "wifi" {print $1}')"

      get_ssid() {
        ${getFromEnv "SSID"}
      }
      get_psk() {
        ${getFromEnv "PSK"}
      }

      ${lib.concatStringsSep "\n\n\n" nmcli-command-blocks}
    '';
in {
  config = lib.mkIf (cfg.enable && cfg.networking.enable) {
    sops.secrets."networking/simple.env" = {
      mode = "0644";
    };

    systemd.services.networkmanager-declarative-wifi-simple = {
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "3s";
        ExecStart = "${bash-script}/bin/add-wifi-networks-simple";
      };
      wantedBy = ["network-online.target"];
    };
  };
}
