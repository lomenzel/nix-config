{
  config,
  pkgs,
  lib,
  colors,
  ...
}:
let
  toBase64 =
    text:
    let
      inherit (lib)
        sublist
        mod
        stringToCharacters
        concatMapStrings
        ;
      inherit (lib.strings) charToInt;
      inherit (builtins)
        substring
        foldl'
        genList
        elemAt
        length
        concatStringsSep
        stringLength
        ;
      lookup = stringToCharacters "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
      sliceN =
        size: list: n:
        sublist (n * size) size list;
      pows = [
        (64 * 64 * 64)
        (64 * 64)
        64
        1
      ];
      intSextets = i: map (j: mod (i / j) 64) pows;
      compose =
        f: g: x:
        f (g x);
      intToChar = elemAt lookup;
      convertTripletInt = sliceInt: concatMapStrings intToChar (intSextets sliceInt);
      sliceToInt = foldl' (acc: val: acc * 256 + val) 0;
      convertTriplet = compose convertTripletInt sliceToInt;
      join = concatStringsSep "";
      convertLastSlice =
        slice:
        let
          len = length slice;
        in
        if len == 1 then
          (substring 0 2 (convertTripletInt ((sliceToInt slice) * 256 * 256))) + "=="
        else if len == 2 then
          (substring 0 3 (convertTripletInt ((sliceToInt slice) * 256))) + "="
        else
          "";
      len = stringLength text;
      nFullSlices = len / 3;
      bytes = map charToInt (stringToCharacters text);
      tripletAt = sliceN 3 bytes;
      head = genList (compose convertTriplet tripletAt) nFullSlices;
      tail = convertLastSlice (tripletAt nFullSlices);

    in
    join (head ++ [ tail ]);
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
    firefox = {
      enable = true;
      #package = firefox-esr;
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

      # Check about:policies#documentation for options.
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
          in
          {
            "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
            "uBlock0@raymondhill.net" = {
              install_url = nameToURL "ublock-origin";
              installation_mode = "force_installed";
            };
            "{4e507435-d65f-4467-a2c0-16dbae24f288}" = {
              install_url = nameToURL "breezedarktheme";
              installation_mode = "force_installed";
            };
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              install_url = nameToURL "bitwarden-password-manager";
              installation_mode = "force_installed";
            };
            "ipfs-firefox-addon@lidel.org" = {
              install_url = nameToURL "ipfs-companion";
              installation_mode = "force_installed";
            };
            "{2ea2bfef-af69-4427-909c-34e1f3f5a418}" = {
              install_url = nameToURL "live-stream-downloader";
              installation_mode = "force_installed";
            };
            "plasma-browser-integration@kde.org" = {
              install_url = nameToURL "plasma-integration";
              installation_mode = "force_installed";
            };
            "idcac-pub@guus.ninja" = {
              install_url = nameToURL "istilldontcareaboutcookies";
              installation_mode = "force_installed";
            };
            "treestyletab@piro.sakura.ne.jp" = {
              install_url = nameToURL "tree-style-tab";
              installation_mode = "force_installed";
            };
            "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
              install_url = nameToURL "return-youtube-dislikes";
              installation_mode = "force_installed";
            };

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
              Value = "about:blank";
              Status = "locked";
            };
            "browser.newtab.url" = {
              Value = "about:blank";
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

            #Toolbar
            "browser.uiCustomization.state" = {
              Value = # json
                ''
                  {
                    "placements": {
                      "widget-overflow-fixed-list":[],
                      "nav-bar":[
                        "treestyletab_piro_sakura_ne_jp-browser-action",
                        "back-button",
                        "forward-button",
                        "stop-reload-button",
                        "customizableui-special-spring1",
                        "urlbar-container",
                        "customizableui-special-spring2",
                        "save-to-pocket-button",
                        "downloads-button",
                        "fxa-toolbar-menu-button",
                        "unified-extensions-button",
                        "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
                      ],
                      "toolbar-menubar":["menubar-items"],
                      "TabsToolbar":[
                        "tabbrowser-tabs",
                        "new-tab-button",
                        "alltabs-button"
                      ],
                      "PersonalToolbar":["personal-bookmarks"],
                      "unified-extensions-area":[
                       
                        "idcac-pub_guus_ninja-browser-action",
                        "ipfs-firefox-addon_lidel_org-browser-action",
                        "plasma-browser-integration_kde_org-browser-action",
                        "ublock0_raymondhill_net-browser-action",
                        "_2ea2bfef-af69-4427-909c-34e1f3f5a418_-browser-action"
                      ]
                    },
                    "seen":[
                      
                      "idcac-pub_guus_ninja-browser-action",
                      "ipfs-firefox-addon_lidel_org-browser-action",
                      "plasma-browser-integration_kde_org-browser-action",
                      "treestyletab_piro_sakura_ne_jp-browser-action",
                      "ublock0_raymondhill_net-browser-action",
                      "_2ea2bfef-af69-4427-909c-34e1f3f5a418_-browser-action",
                      "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action",
                      "developer-button"
                    ],
                    "dirtyAreaCache":[
                      "unified-extensions-area",
                      "TabsToolbar",
                      "nav-bar"
                    ],
                    "currentVersion":19,
                    "newElementCount":4
                  }
                '';
              Status = "locked";
            };
          };
      };
    };
  };

}
