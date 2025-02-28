{
  config,
  pkgs,
  lib,
  colors,
  helper-functions,
  ...
}:
with (helper-functions { inherit lib; });
let
  css-colors =
    with config.lib.stylix.colors; # css
    ''
      :root {
        --background-color: #${base00};
        --base00: #${base00};

        --lighter-background: #${base01};
        --base01: #${base01};

        --selection-background: #${base02};
        --base02: #${base02};

        --comments-line-highlight: #${base03};
        --base03: #${base03};

        --dark-foreground: #${base04};
        --base04: #${base04};

        --default-foreground: #${base05};
        --base05: #${base05};

        --light-foreground: #${base06};
        --base06: #${base06};

        --light-background-text: #${base07};
        --base07: #${base07};

        --variables-tags-error: #${base08};
        --base08: #${base08};

        --integers-constants-attributes: #${base09};
        --base09: #${base09};

        --classes-keywords-storage: #${base0A};
        --base0A: #${base0A};

        --strings-markup-code: #${base0B};
        --base0B: #${base0B};

        --support-regular-expressions: #${base0C};
        --base0C: #${base0C};

        --functions-methods: #${base0D};
        --base0D: #${base0D};

        --keywords-selectors: #${base0E};
        --base0E: #${base0E};

        --deprecated-debugging: #${base0F};
        --base0F: #${base0F};

        /* Typical use cases */
        --link-color: var(--integers-constants-attributes); /* Using base09 */
        --visited-link-color: var(--functions-methods); /* Using base0D */
        --active-link-color: var(--variables-tags-error); /* Using base08 */
        --hover-link-color: var(--classes-keywords-storage); /* Using base0A */

        --accent-color: var(--base0D); /* Using base0D */
        --accent-color-light: var(--strings-markup-code); /* Using base0B */
        --accent-color-dark: var(--support-regular-expressions); /* Using base0C */
        --inactive-window-accent-color: var(--comments-line-highlight); /* Using base03 */


        --border-color: var(--comments-line-highlight); /* Using base03 */
        --input-border-color: var(--dark-foreground); /* Using base04 */
        --button-border-color: var(--default-foreground); /* Using base05 */

        --text-color: var(--default-foreground); /* Using base05 */
        --muted-text-color: var(--comments-line-highlight); /* Using base03 */
        --heading-text-color: var(--dark-foreground); /* Using base04 */

        --button-background-color: var(--selection-background); /* Using base02 */
        --button-text-color: var(--light-foreground); /* Using base06 */

        --navbar-background-color: var(--background-color); /* Using base00 */
        --navbar-text-color: var(--light-foreground); /* Using base06 */

        --sidebar-background-color: var(--lighter-background); /* Using base01 */
        --sidebar-text-color: var(--light-foreground); /* Using base06 */

        --toolbar-background-color: var(--background-color); /* Using base00 */
        --toolbar-text-color: var(--light-foreground); /* Using base06 */

        --tooltip-background-color: var(--dark-foreground); /* Using base04 */
        --tooltip-text-color: var(--light-foreground); /* Using base06 */
      }

    '';

in
{

  programs = with pkgs; {
    librewolf = {
      enable = true;
      #package = pkgs.librewolf;
      nativeMessagingHosts = with pkgs.kdePackages; [ plasma-browser-integration ];
      profiles.default = {
        userChrome = ''
          ${css-colors}
          ${builtins.readFile ./userChrome.css}
        '';
        userContent = ''
          ${css-colors}
          ${builtins.readFile ./userContent.css}
        '';
        search = {
          engines = {
            "wsh" = {
              urls = [ { template = "http://localhost:8012/{searchTerms}"; } ];
            };
          };
          default = "wsh";
        };

      };
      policies = {

        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        DisableAccounts = true;
        DisableFirefoxScreenshots = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        OfferToSaveLogins = false;
        DontCheckDefaultBrowser = true;
        DisplayBookmarksToolbar = "never";
        DisplayMenuBar = "default-off";
        SearchBar = "unified";

        ExtensionSettings =
          let
            nameToURL = name: "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
            extension = name: {
              install_url = nameToURL name;
              installation_mode = "force_installed";
            };
          in
          {
            "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
            "uBlock0@raymondhill.net" = extension "ublock-origin";
            "{4e507435-d65f-4467-a2c0-16dbae24f288}" = extension "breezedarktheme";
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = extension "bitwarden-password-manager";
            "ipfs-firefox-addon@lidel.org" = extension "ipfs-companion";
            "{2ea2bfef-af69-4427-909c-34e1f3f5a418}" = extension "live-stream-downloader";
            "plasma-browser-integration@kde.org" = extension "plasma-integration";
            "idcac-pub@guus.ninja" = extension "istilldontcareaboutcookies";
            "treestyletab@piro.sakura.ne.jp" = extension "tree-style-tab";
            "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = extension "return-youtube-dislikes";
            "sponsorBlocker@ajay.app" = extension "sponsorblock";
            "{34daeb50-c2d2-4f14-886a-7160b24d66a4}" = extension "youtube-shorts-block";
            "{88ebde3a-4581-4c6b-8019-2a05a9e3e938}" = extension "hide-youtube-shorts";
            "deArrow@ajay.app" = extension "dearrow";
            "{c3348e96-6d84-47dc-8252-4b8493299efc}" = extension "nyan-cat-youtube-enhancement";
            "{f0bb47a1-a5b1-4a4c-80fb-556d6a60e45c}" = extension "no-gender";
          };

        "3rdparty".Extensions = {
          "treestyletab@piro.sakura.ne.jp" = {

            __ConfigsMigration__userValeusSameToDefaultAreCleared = true;
            chunkedUserStyleRules0 = toBase64 ''
              ${css-colors}
              ${builtins.readFile ./tst.css}
            '';

            configsVersion = 31;
            notifiedFeaturesVersion = 9;
            optionsExpandedGroups = [ "group-allConfigs" ];
            optionsExpandedSections = [
              "section-advanced"
              "section-debug"
            ];
            showExpertOptions = true;
            syncDevices = {
              device-1715622178665-56471 = {
                id = "device-1715622178665-56471";
                name = "Firefox on Linux";
                icon = "device-desktop";
                timestamp = 1715887311185;
              };
              device-1715892191672-35004 = {
                id = "device-1715892191672-35004";
                name = "Firefox on Linux";
                icon = "device-desktop";
                timestamp = 1715928836601;
              };
            };
            userStyleRules = "";
            userStyleRules0 = "";
            userStyleRules1 = "";
            userStyleRules2 = "";
            userStyleRules3 = "";
            userStyleRules4 = "";
            userStyleRules5 = "";
            userStyleRules6 = "";
            userStyleRules7 = "";
            userStyleRulesFieldHeight = "596px";

          };
        };

        # about:config
        Preferences =
          let
            lock-false = {
              Value = false;
              Status = "locked";
            };
            lock-true = {
              Value = true;
              Status = "locked";
            };
          in
          {
            "widget.use-xdg-desktop-portal.file-picker" = {
              Value = 1;
              Status = "locked";
            };
            "browser.download.useDownloadDir" = lock-false;
            "browser.startup.homepage" = {
              Value = "about:newtab";
              Status = "locked";
            };
            "browser.newtab.url" = {
              Value = "about:newtab";
              Status = "locked";
            };
            "browser.contentblocking.category" = {
              Value = "strict";
              Status = "locked";
            };
            "extensions.pocket.enabled" = lock-false;
            "extensions.screenshots.disabled" = lock-true;
            "browser.topsites.contile.enabled" = lock-false;
            "browser.formfill.enable" = lock-false;
            "browser.search.suggest.enabled" = lock-false;
            "browser.search.suggest.enabled.private" = lock-false;
            "browser.urlbar.suggest.searches" = lock-false;
            "browser.urlbar.showSearchSuggestionsFirst" = lock-false;
            "browser.translations.automaticallyPopup" = lock-false;
            "toolkit.legacyUserProfileCustomizations.stylesheets" = lock-true;
            "widget.gtk.global-menu.enabled" = lock-true;
            "widget.gtk.global-menu.wayland.enabled" = lock-true;

            #Toolbar
            "browser.uiCustomization.state" = {
              Value = builtins.toJSON {
                placements = {
                  widget-overflow-fixed-list = [ ];
                  nav-bar = [
                    "treestyletab_piro_sakura_ne_jp-browser-action"
                    "back-button"
                    "forward-button"
                    "stop-reload-button"
                    "customizableui-special-spring1"
                    "urlbar-container"
                    "customizableui-special-spring2"
                    "downloads-button"
                    "fxa-toolbar-menu-button"
                    "unified-extensions-button"
                    "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
                  ];
                  toolbar-menubar = [ "menubar-items" ];
                  TabsToolbar = [
                    "tabbrowser-tabs"
                    "new-tab-button"
                    "alltabs-button"
                  ];
                  PersonalToolbar = [ "personal-bookmarks" ];
                  unified-extensions-area = [
                    "dearrow_ajay_app-browser-action"
                    "sponsorblocker_ajay_app-browser-action"
                    "idcac-pub_guus_ninja-browser-action"
                    "ipfs-firefox-addon_lidel_org-browser-action"
                    "plasma-browser-integration_kde_org-browser-action"
                    "ublock0_raymondhill_net-browser-action"
                    "_2ea2bfef-af69-4427-909c-34e1f3f5a418_-browser-action"
                    "_34daeb50-c2d2-4f14-886a-7160b24d66a4_-browser-action"
                    "_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action"
                    "_88ebde3a-4581-4c6b-8019-2a05a9e3e938_-browser-action"
                  ];
                };
                seen = [
                  "idcac-pub_guus_ninja-browser-action"
                  "ipfs-firefox-addon_lidel_org-browser-action"
                  "plasma-browser-integration_kde_org-browser-action"
                  "treestyletab_piro_sakura_ne_jp-browser-action"
                  "ublock0_raymondhill_net-browser-action"
                  "_2ea2bfef-af69-4427-909c-34e1f3f5a418_-browser-action"
                  "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
                  "developer-button"
                  "_34daeb50-c2d2-4f14-886a-7160b24d66a4_-browser-action"
                  "_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action"
                  "_88ebde3a-4581-4c6b-8019-2a05a9e3e938_-browser-action"
                  "sponsorblocker_ajay_app-browser-action"
                  "dearrow_ajay_app-browser-action"
                ];
                dirtyAreaCache = [
                  "unified-extensions-area"
                  "TabsToolbar"
                  "nav-bar"
                  "toolbar-menubar"
                  "PersonalToolbar"
                ];
                currentVersion = 20;
                newElementCount = 4;
              };
              Status = "locked";
            };
          };
      };
    };
  };

}
