{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup;
  cfgFf = cfg.firefox;

  extensions = import ./extensions {inherit pkgs lib config;};

  firefox-package =
    if (cfgFf.enableExtensions && cfg.desktopEnvironments.gnome.enable)
    then
      (pkgs.firefox.override {
        nativeMessagingHosts = [pkgs.gnome-browser-connector];
      })
    else pkgs.firefox;
in {
  config = lib.mkIf cfgFf.enable {
    setup.impermanence = {
      keepDirs = [
        ".cache/mozilla/firefox"
        ".mozilla/firefox"
      ];
    };

    programs.firefox = {
      enable = true;
      package = firefox-package;
      profiles = {
        "${cfg.username}" = {
          id = 0;
          inherit extensions;
          settings = {
            "browser.bookmarks.showMobileBookmarks" = true;
            "browser.contentblocking.category" = "strict"; # Block cookies

            "browser.download.always_ask_before_handling_new_types" = true;
            "browser.download.dir" = "${config.xdg.userDirs.download}";

            # Configure what the new tab page looks like
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
            "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
            "browser.newtabpage.activity-stream.feeds.telemetry" = false;
            "browser.newtabpage.activity-stream.feeds.topsites" = false;
            "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = false;
            "browser.newtabpage.activity-stream.section.highlights.includeVisited" = false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.telemetry" = false;

            "browser.search.region" = "GB";
            "browser.search.suggest.enabled" = false; # Don't make suggestions when searching
            "browser.sessionstore.warnOnQuit" = true;
            "browser.startup.page" = 3; # Restore tabs when opening
            "browser.tabs.inTitlebar" = 1;
            "browser.tabs.warnOnClose" = true;
            "browser.toolbars.bookmarks.visibility" = "never"; # Disable the bookmarks bar

            # Enable translations
            "browser.translations.automaticallyPopup" = false;
            "browser.translations.enable" = true;
            "browser.translations.panelShown" = true;

            # Configure urlbar
            "browser.urlbar.placeholderName" = "DuckDuckGo";
            "browser.urlbar.placeholderName.private" = "DuckDuckGo";
            "browser.urlbar.quicksuggest.scenario" = "history";
            "browser.urlbar.showSearchSuggestionsFirst" = false;
            # I'm fine with pre-fetching, but only after I've searched
            "browser.urlbar.speculativeConnect.enabled" = false;
            "browser.urlbar.suggest.history" = false;

            # Dev tools window
            "devtools.everOpened" = true;
            "devtools.gridinspector.showGridAreas" = true;
            "devtools.toolbox.tabsOrder" =
              builtins.concatStringsSep ","
              [
                "inspector"
                "jsdebugger"
                "webconsole"
                "netmonitor"
                "styleeditor"
                "performance"
                "memory"
                "storage"
                "accessibility"
                "application"
              ];

            # DNS-over-HTTPS
            "doh-rollout.home-region" = "GB";
            "dom.forms.autocomplete.formautofill" = true;

            "extensions.activeThemeID" = "default-theme@mozilla.org";
            "extensions.formautofill.creditCards.enabled" = false;
            "extensions.pocket.enabled" = false;
            "extensions.ui.dictionary.hidden" = true;
            "extensions.ui.extension.hidden" = false;
            "extensions.ui.locale.hidden" = false;
            "extensions.ui.plugin.hidden" = false;
            "extensions.ui.sitepermission.hidden" = true;

            # Highlight all matches when doing Ctrl-F
            "findbar.highlightAll" = true;

            # Set device name
            "identity.fxaccounts.account.device.name" = "${cfg.username}'s Firefox on ${cfg.hostname}";

            # Auto-play DRM-controlled HTML5 content
            "media.eme.enabled" = true;

            # Pre-fetching allows Firefox to fetch pages before I click them by
            # guessing which links I might click. It is a privacy concern, but I'm
            # not too fussed and I'd rather have faster load times
            "network.dns.disablePrefetch" = false;
            "network.http.speculative-parallel-limit" = 4;
            "network.predictor.enabled" = true;
            "network.prefetch-next" = true;

            "privacy.donottrackheader.enabled" = true;
            "privacy.fingerprintingProtection" = true;
            "privacy.query_stripping.enabled" = true;
            "privacy.query_stripping.enabled.pbmode" = true;
            "privacy.trackingprotection.emailtracking.enabled" = true;
            "privacy.trackingprotection.enabled" = true;
            "privacy.trackingprotection.socialtracking.enabled" = true;

            "reader.color_scheme" = "light";

            "signon.autofillForms" = false;
            "signon.generation.enabled" = false;
            "signon.management.page.breach-alerts.enabled" = false;
            "signon.rememberSignons" = false;
          };
        };
        basic = {
          id = 1;
          settings = {
            "browser.download.always_ask_before_handling_new_types" = true;
            "browser.download.dir" = "${config.home.homeDirectory}/Downloads";

            # Configure what the new tab page looks like
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
            "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
            "browser.newtabpage.activity-stream.feeds.telemetry" = false;
            "browser.newtabpage.activity-stream.feeds.topsites" = false;
            "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = false;
            "browser.newtabpage.activity-stream.section.highlights.includeVisited" = false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.telemetry" = false;

            "browser.search.region" = "GB";
            "browser.search.suggest.enabled" = false; # Don't make suggestions when searching
            "browser.sessionstore.warnOnQuit" = true;
            "browser.startup.page" = 1; # Start on home page (new tab)
            "browser.tabs.inTitlebar" = 1;
            "browser.tabs.warnOnClose" = true;
            "browser.toolbars.bookmarks.visibility" = "never"; # Disable the bookmarks bar

            # Enable translations
            "browser.translations.automaticallyPopup" = false;
            "browser.translations.enable" = true;
            "browser.translations.panelShown" = true;

            # Configure urlbar
            "browser.urlbar.placeholderName" = "DuckDuckGo";
            "browser.urlbar.placeholderName.private" = "DuckDuckGo";
            "browser.urlbar.quicksuggest.scenario" = "history";
            "browser.urlbar.showSearchSuggestionsFirst" = false;

            "extensions.activeThemeID" = "default-theme@mozilla.org";
            "extensions.formautofill.creditCards.enabled" = false;
            "extensions.pocket.enabled" = false;
            "extensions.ui.dictionary.hidden" = true;
            "extensions.ui.extension.hidden" = false;
            "extensions.ui.locale.hidden" = false;
            "extensions.ui.plugin.hidden" = false;
            "extensions.ui.sitepermission.hidden" = true;

            # Highlight all matches when doing Ctrl-F
            "findbar.highlightAll" = true;

            # Set device name
            "identity.fxaccounts.account.device.name" = "${cfg.username}'s Firefox (basic profile) on ${cfg.hostname}";

            "reader.color_scheme" = "light";
          };
        };
      };
    };
  };
}
