{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.secrets;

  getFromEnv = type: ''
    grep --color=never -Po "(?<=${type}=)\S+" ${
      config.sops.secrets."networking/complex/eduroam.env".path
    }
  '';

  bash-script = pkgs.writeShellApplication {
    name = "add-wifi-network-eduroam";
    runtimeInputs = with pkgs; [
      networkmanager
      gawk
      gnugrep
    ];
    text = ''
      wifi_device="$(nmcli device | awk '$2 == "wifi" {print $1}')"

      get_identity() {
        ${getFromEnv "IDENTITY"}
      }
      get_password() {
        ${getFromEnv "PASSWORD"}
      }

      nmcli connection delete eduroam || true
      nmcli connection add type wifi con-name eduroam ifname "$wifi_device" ssid eduroam
      nmcli connection modify eduroam 802-1x.eap peap 802-1x.identity "$(get_identity)" 802-1x.phase2-auth mschapv2 802-1x.ca-cert /etc/ssl/certs/ca-certificates.crt 802-1x.password "$(get_password)" 802-11-wireless-security.key-mgmt wpa-eap
    '';
  };
in
{
  config = lib.mkIf (cfg.enable && cfg.networking.enable && cfg.networking.complex.eduroam) {
    sops.secrets."networking/complex/eduroam.env" = {
      mode = "0644";
    };

    systemd.services.networkmanager-declarative-wifi-eduroam = {
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "3s";
        ExecStart = "${bash-script}/bin/add-wifi-network-eduroam";
      };
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
    };
  };
}
