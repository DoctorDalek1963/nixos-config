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

      wantedBy = ["transmission.service"];

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
    systemd.tmpfiles.rules = ["d ${dir} 0755 root root - -"];

    systemd = {
      services = mkService {
        name = "mam-dynamic-ip";
        description = "Handle dynamic VPN IPs for MAM";
        script = let
          updateProwlarr = pkgs.writers.writePython3 "mam_dynamic_ip_update_prowlarr.py" {} ''
            import json
            import os
            import re
            import sqlite3
            from urllib.parse import unquote

            PROWLARR_DB_PATH = "/var/lib/prowlarr/prowlarr.db"
            COOKIES_PATH = "${dir}/mam.cookies"
            WHERE_CLAUSE = (
                "WHERE Implementation == 'MyAnonamouse' AND "
                + "ConfigContract == 'MyAnonamouseSettings'"
            )


            def get_new_mam_id() -> str:
                with open(COOKIES_PATH, "r") as f:
                    return unquote(
                        re.search(
                            r"^\.myanonamouse.net.+mam_id\s+([a-zA-Z0-9%]+)$",
                            f.read(),
                            re.MULTILINE
                        ).group(1)
                    )


            def main() -> None:
                if not os.path.exists(PROWLARR_DB_PATH):
                    raise RuntimeError(f"Database at {PROWLARR_DB_PATH} doesn't exist")

                conn = sqlite3.connect(PROWLARR_DB_PATH)
                cur = conn.cursor()

                [(settings,)] = cur.execute(
                    f"SELECT Settings FROM Indexers {WHERE_CLAUSE}"
                ).fetchmany()

                new_settings = json.dumps(
                    json.loads(settings) | {"mamId": get_new_mam_id()}, indent=2
                )

                cur.execute(
                    f"UPDATE Indexers SET Settings = ? {WHERE_CLAUSE}",
                    (new_settings,)
                )

                conn.commit()


            if __name__ == "__main__":
                main()
          '';
        in
          # bash
          ''
            if [[ -f ${dir}/mam.cookies ]]; then
              ${pkgs.curl}/bin/curl -v -c ${dir}/mam.cookies -b ${dir}/mam.cookies \
                https://t.myanonamouse.net/json/dynamicSeedbox.php \
                && ${updateProwlarr}
            else
              echo "ERROR: ${dir}/mam.cookies does not exist"
              echo "Please create a new session ID on MAM (Preferences > Security) with the following IP:"
              ${pkgs.curl}/bin/curl ipinfo.io/ip
              echo "IMPORTANT: Make sure to allow this session to set a dynamic IP"
              echo "Then run this command:"
              echo 'echo "mam_id=loooooongSessionId" | sudo tee ${dir}/mam.cookies'
              exit 1
            fi
          '';
      };

      timers = mkTimer "mam-dynamic-ip" "0/2:00:00";
    };
  };
}
