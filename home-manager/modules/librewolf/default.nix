{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: let
  cfg = config.setup;
  cfgFf = cfg.librewolf;

  extensions = import ./extensions {inherit pkgs lib config;};

  common-profile = {
    search = {
      default = "DuckDuckGo";
      privateDefault = "DuckDuckGo";
    };

    settings = {
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
      "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.havePinned" = "";
      "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.searchEngines" = "";

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

      "extensions.activeThemeID" = "default-theme@mozilla.org";
      "extensions.formautofill.creditCards.enabled" = false;
      "extensions.pocket.enabled" = false;
      "extensions.ui.dictionary.hidden" = true;
      "extensions.ui.extension.hidden" = false;
      "extensions.ui.locale.hidden" = false;
      "extensions.ui.plugin.hidden" = false;
      "extensions.ui.sitepermission.hidden" = true;

      # All my extensions are managed with Nix, so I can enable them all
      # automatically on a fresh install
      "extensions.autoDisableScopes" = 0;

      # Highlight all matches when doing Ctrl-F
      "findbar.highlightAll" = true;

      # Enable Firefox Sync
      "identity.fxaccounts.enabled" = true;

      # Auto-play DRM-controlled HTML5 content
      "media.eme.enabled" = true;

      # WebGL is a strong fingerprinting vector and LibreWolf disables it
      # by default, but I like to have it
      "webgl.disabled" = false;

      "privacy.donottrackheader.enabled" = true;
      "privacy.fingerprintingProtection" = true;
      "privacy.resistFingerprinting" = true;
      "privacy.query_stripping.enabled" = true;
      "privacy.query_stripping.enabled.pbmode" = true;
      "privacy.trackingprotection.emailtracking.enabled" = true;
      "privacy.trackingprotection.enabled" = true;
      "privacy.trackingprotection.socialtracking.enabled" = true;

      "privacy.clearOnShutdown.cache" = true;
      "privacy.clearOnShutdown.cookies" = false;
      "privacy.clearOnShutdown.downloads" = true;
      "privacy.clearOnShutdown.formdata" = true;
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.offlineApps" = false;
      "privacy.clearOnShutdown.openWindows" = false;
      "privacy.clearOnShutdown.sessions" = false;
      "privacy.clearOnShutdown.siteSettings" = false;
      "privacy.clearOnShutdown_v2.cache" = true;
      "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
      "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = false;
      "privacy.clearOnShutdown_v2.siteSettings" = false;

      "reader.color_scheme" = "light";
    };
  };
in {
  config = lib.mkIf cfgFf.enable {
    setup.impermanence = {
      keepDirs = [
        ".cache/mozilla/firefox"
        ".mozilla/firefox"
        ".cache/librewolf"
        ".librewolf"
      ];
    };

    programs.librewolf = {
      enable = true;

      nativeMessagingHosts =
        lib.optional
        (cfgFf.enableExtensions && osConfig.setup.desktopEnvironments.gnome.enable)
        pkgs.gnome-browser-connector;

      profiles = {
        "${cfg.username}" = lib.mkMerge [
          common-profile
          {
            id = 0;
            inherit extensions;

            settings = {
              "browser.bookmarks.showMobileBookmarks" = true;
              "browser.contentblocking.category" = "strict"; # Block cookies

              "browser.tabs.groups.enabled" = true;
              "browser.fullscreen.autohide" = false; # Don't hide tabs in fullscreen

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

              # Set device name
              "identity.fxaccounts.account.device.name" = "${cfg.username}'s LibreWolf on ${osConfig.setup.hostname}";

              # Pre-fetching allows the browser to fetch pages before I click them by
              # guessing which links I might click. It is a privacy concern, but I'm
              # not too fussed and I'd rather have faster load times
              "network.dns.disablePrefetch" = false;
              "network.http.speculative-parallel-limit" = 4;
              "network.predictor.enabled" = true;
              "network.prefetch-next" = true;

              "signon.autofillForms" = false;
              "signon.generation.enabled" = false;
              "signon.management.page.breach-alerts.enabled" = false;
              "signon.rememberSignons" = false;
            };
          }
        ];
        basic = lib.mkMerge [
          common-profile
          {
            id = 1;
            settings = {
              # Set device name
              "identity.fxaccounts.account.device.name" = "${cfg.username}'s LibreWolf (basic profile) on ${osConfig.setup.hostname}";
            };
          }
        ];
      };
    };
  };
}
