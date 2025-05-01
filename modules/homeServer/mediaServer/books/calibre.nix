{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  libraryPath = "${cfgMs.mediaRoot}/ebooks";

  users-db-pkg = pkgs.stdenvNoCC.mkDerivation {
    name = "calibre-server-users.db";

    dontUnpack = true;
    dontConfigure = true;

    nativeBuildInputs = [pkgs.sqlite];

    buildPhase = ''
      sqlite3 users.db ".read ${pkgs.writeText "new-calibre-server-users.sql" ''
        CREATE TABLE users (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            pw TEXT NOT NULL,
            timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
            session_data TEXT NOT NULL DEFAULT "{}",
            restriction TEXT NOT NULL DEFAULT "{}",
            readonly TEXT NOT NULL DEFAULT "n",
            misc_data TEXT NOT NULL DEFAULT "{}",
            UNIQUE(name)
        );

        INSERT INTO users (name, pw, timestamp, restriction) VALUES ('admin', 'admin', datetime(0, 'unixepoch'), '{"library_restrictions": {}}');
      ''}"
    '';

    installPhase = ''
      mkdir $out
      cp users.db $out/users.db
    '';
  };
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable && cfgMs.books) {
    setup = {
      impermanence.keepDirs = [
        "/var/lib/calibre-server"
        "/var/lib/calibre-web"
      ];
      backup.paths = [
        "/var/lib/calibre-web"
      ];
    };

    services = {
      nginx.virtualHosts."${cfg.domainName}".locations = {
        "/calibre" = {
          proxyPass = "http://localhost:${toString cfg.ports.mediaServer.calibre.web}";
          extraConfig = "proxy_set_header X-Script-Name /calibre;";
        };
      };

      calibre-server = {
        enable = true;
        group = "media";

        host = "0.0.0.0";
        port = cfg.ports.mediaServer.calibre.server;

        libraries = ["${libraryPath}"];

        auth = {
          enable = true;
          mode = "basic";
          userDb = "${users-db-pkg}/users.db";
        };
      };

      calibre-web = {
        enable = true;
        group = "media";

        listen = {
          ip = "0.0.0.0";
          port = cfg.ports.mediaServer.calibre.web;
        };

        options = {
          calibreLibrary = "${libraryPath}";
          enableBookConversion = true;
          enableBookUploading = true;
        };
      };
    };

    systemd.services = {
      calibre-server = {
        requires = ["create-calibre-library.service"];
        after = ["create-calibre-library.service"];
      };

      calibre-web = {
        requires = ["create-calibre-library.service"];
        after = ["create-calibre-library.service"];
      };

      create-calibre-library = {
        description = "Create a new calibre library if ${libraryPath} doesn't exist";

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.writeShellScript "create-calibre-library" ''
            if [[ ! -d "${libraryPath}" ]]; then
              mkdir -p "${libraryPath}"/.calnotes

              ${pkgs.calibre}/bin/calibredb restore_database --library-path="${libraryPath}" --really-do-it

              chown -R calibre-server:media "${libraryPath}"
            fi
          ''}";
        };
      };
    };
  };
}
