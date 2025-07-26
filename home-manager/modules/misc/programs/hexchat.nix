{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup;

  hexchat-theme =
    {
      "catppuccin-macchiato" =
        let
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "hexchat";
            rev = "f84284c9d8363066d04c262717750cad623c1e8c";
            hash = "sha256-yTTHRjKv4PmB+pvxlI1jHBfiCAfquAdwBnPPl5viRr8=";
            sparseCheckout = [ "macchiato/colors.conf" ];
          };
        in
        pkgs.stdenvNoCC.mkDerivation {
          name = "catppuccin-macchiato-hexchat-theme";
          inherit src;
          dontUnpack = true;
          installPhase = ''
            mkdir -p $out
            cp $src/macchiato/colors.conf $out/colors.conf
          '';
        };
    }
    .${cfg.terminal.theme} or null;
in
{
  config = lib.mkIf cfg.misc.programs.hexchat {
    programs.hexchat = rec {
      enable = true;
      theme = hexchat-theme;
      overwriteConfigFiles = true;

      settings = {
        irc_nick1 = "doctordalek";
        irc_nick2 = "doctordalek1963";
        irc_nick3 = "doctor_dalek1963";
        irc_user_name = "doctordalek";
        irc_real_name = "Dyson";

        away_auto_unmark = "0";
        away_omit_alerts = "1";
        away_reason = "I'm busy";
        away_show_once = "1";
        away_size_max = "300";
        away_timeout = "60";
        away_track = "1";
        gui_slist_skip = "1";
        gui_tray = "1";
        gui_tray_away = "1";
        gui_tray_blink = "1";
        gui_tray_close = "1";
        gui_tray_minimize = "0";
        gui_tray_quiet = "0";
        irc_auto_rejoin = "0";
        irc_reconnect_rejoin = "1";
        irc_ban_type = "1";
        irc_invisible = "0";
        irc_join_delay = "5";
        irc_logging = "1";
        irc_logmask = "%n/%c.log";
        irc_nick_hilight = "irc_no_hilight = NickServ,ChanServ,InfoServ,N,Q";
        irc_notice_pos = "0";
        stamp_log = "1";
        stamp_log_format = "%b %d %H:%M:%S ";
        stamp_text = "1";
        stamp_text_format = "[%H:%M:%S] ";
        text_autocopy_color = "0";
        text_autocopy_stamp = "0";
        text_autocopy_text = "0";
        text_color_nicks = "1";
        text_font = "Hack Nerd Font Mono 10";
        text_font_main = "Hack Nerd Font Mono 10";
        text_indent = "1";
        text_max_lines = "5000";
        text_replay = "1";
        text_search_case_match = "0";
        text_search_highlight_all = "1";
        text_search_follow = "1";
        text_search_regexp = "1";
        text_show_marker = "1";
        text_show_sep = "1";
        text_spell_langs = "en_GB";
        text_stripcolor_msg = "0";
        text_stripcolor_replay = "1";
        text_stripcolor_topic = "1";
        text_thin_sep = "1";
        text_transparent = "0";
        text_wordwrap = "1";
      };

      channels =
        let
          optPassword =
            name:
            if cfg.secrets.enable then
              { password = "READPASSWORD(${config.sops.secrets."irc/${name}/password".path})"; }
            else
              { };

          mkServerConfig =
            {
              serverName,
              server,
              userName,
              autojoin,
            }:
            {
              inherit userName;

              realName = "Dyson";
              servers = [ server ];
              loginMethod = "sasl";

              nickname = settings.irc_nick1;
              nickname2 = settings.irc_nick2;

              inherit autojoin;
              charset = "UTF-8 (Unicode)";
              options = {
                acceptInvalidSSLCertificates = false;
                autoconnect = true;
                connectToSelectedServerOnly = true;
                useGlobalUserInformation = false;
                forceSSL = true;
              };
            }
            // optPassword serverName;
        in
        {
          libera = mkServerConfig {
            serverName = "libera";
            server = "irc.libera.chat";
            userName = "doctordalek";
            autojoin = [
              "#linux"
              "#nixos"
              "##rust"
            ];
          };
          oftc = mkServerConfig {
            serverName = "oftc";
            server = "irc.oftc.net";
            userName = "doctordalek";
            autojoin = [
              "#home-manager"
              "#linux"
            ];
          };
        };
    };

    home.activation = lib.mkIf (cfg.secrets.enable && cfg.misc.programs.hexchat) {
      populateHexchatPasswords =
        let
          raw-python-script = pkgs.writeScript "populate-hexchat-passwords" ''
            #!/usr/bin/env python

            import os
            import re

            SERVLIST_PATH = "${config.xdg.configHome}/hexchat/servlist.conf"


            def main() -> None:
                with open(SERVLIST_PATH, "r") as f:
                    servlist = f.read()

                new_servlist = servlist

                for filename in re.findall(r"READPASSWORD\(([/\a-zA-Z0-9_-]*?)\)", servlist):
                    with open(filename, "r") as f:
                        password = f.read().strip()

                    new_servlist = new_servlist.replace(f"READPASSWORD({filename})", password)

                os.remove(SERVLIST_PATH)

                with open(SERVLIST_PATH, "w") as f:
                    f.write(new_servlist)


            if __name__ == "__main__":
                main()
          '';
          populate = pkgs.stdenvNoCC.mkDerivation {
            name = "populate-hexchat-passwords";
            src = raw-python-script;

            dontUnpack = true;
            buildInputs = with pkgs; [ python311 ];

            installPhase = ''
              mkdir -p $out/bin
              cp $src $out/bin/populate-hexchat-passwords
            '';
          };
        in
        lib.hm.dag.entryAfter [
          "writeBoundary"
          "sops-nix"
          "restartSopsNix"
        ] "$DRY_RUN_CMD ${populate}/bin/populate-hexchat-passwords";
    };
  };
}
