{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.secrets;

  python-script =
    pkgs.writeText "generate_networkmanager_declarative_connections.py"
    # python
    ''
      #!/usr/bin/env python3

      import re


      def read_env_file() -> dict[str, str]:
          env_map = dict()
          with open("${config.sops.secrets."networking.env".path}", "r") as f:
              for line in f.read().splitlines():
                  if m := re.match(r"^\s*([a-zA-Z0-9_-]+)\s*=\s*(\S+)\s*$", line):
                      key, value = m.groups()
                      env_map[key] = value

          return env_map


      def to_filename(ssid: str) -> str:
          return ssid.replace(" ", "-")


      def main() -> None:
          network_names = [${builtins.concatStringsSep ", " (map (x: ''"${toString x}"'') cfg.networking.simpleWifiNetworkNames)}]
          env_map = read_env_file()

          for name in network_names:
              ssid = env_map[f"{name}_SSID"]  # Crash if not defined
              psk = env_map.get(f"{name}_PSK")  # Possibly None if the WiFi is public

              security = (
                  f"""
      [wifi-security]
      key-mgmt=wpa-psk
      psk={psk}
              """
                  if psk is not None
                  else ""
              )

              with open(
                  f"/etc/NetworkManager/system-connections/{to_filename(ssid)}.nmconnection",
                  "w",
              ) as f:
                  f.write(
                      f"""
      [connection]
      id={ssid}
      type=wifi

      [wifi]
      ssid={ssid}

      {security}
                  """
                  )


      if __name__ == "__main__":
          main()
    '';

  python-script-drv = pkgs.stdenv.mkDerivation {
    name = "generate-networkmanager-declarative-connections";
    propagatedBuildInputs = [pkgs.python3];
    dontUnpack = true;
    installPhase = "install -Dm744 ${python-script} $out/bin/generate-networkmanager-declarative-connections";
  };
in {
  config = lib.mkIf (cfg.enable && cfg.networking.enable) {
    sops.secrets."networking.env" = {
      mode = "0644";
    };

    systemd.services.networkmanager-declarative-connections = {
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${python-script-drv}/bin/generate-networkmanager-declarative-connections";
      };
      wantedBy = ["multi-user.target"];
    };
  };
}
