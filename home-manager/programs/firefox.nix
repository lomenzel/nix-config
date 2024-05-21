{ config, pkgs, lib, ... }:
let

  accentColor = "#744A8A";
  inactiveAccentColor = "#2E2A39";
  inactiveSelected = "#463054";
 
  toBase64 = text: let
    inherit (lib) sublist mod stringToCharacters concatMapStrings;
    inherit (lib.strings) charToInt;
    inherit (builtins) substring foldl' genList elemAt length concatStringsSep stringLength;
    lookup = stringToCharacters "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    sliceN = size: list: n: sublist (n * size) size list;
    pows = [(64 * 64 * 64) (64 * 64) 64 1];
    intSextets = i: map (j: mod (i / j) 64) pows;
    compose = f: g: x: f (g x);
    intToChar = elemAt lookup;
    convertTripletInt = sliceInt: concatMapStrings intToChar (intSextets sliceInt);
    sliceToInt = foldl' (acc: val: acc * 256 + val) 0;
    convertTriplet = compose convertTripletInt sliceToInt;
    join = concatStringsSep "";
    convertLastSlice = slice: let
      len = length slice;
    in
      if len == 1
      then (substring 0 2 (convertTripletInt ((sliceToInt slice) * 256 * 256))) + "=="
      else if len == 2
      then (substring 0 3 (convertTripletInt ((sliceToInt slice) * 256))) + "="
      else "";
    len = stringLength text;
    nFullSlices = len / 3;
    bytes = map charToInt (stringToCharacters text);
    tripletAt = sliceN 3 bytes;
    head = genList (compose convertTriplet tripletAt) nFullSlices;
    tail = convertLastSlice (tripletAt nFullSlices);
  
  in
    join (head ++ [tail]);
  css-colors = ''
  :root {
            --config-accent-color: ${accentColor};
            --config-dimmed-accent-color: ${inactiveSelected};
            --config-tinted-background: ${inactiveAccentColor};
          }
  '';

in {

  programs = with pkgs; {
    firefox = {
      enable = true;
      package = firefox-esr;
      nativeMessagingHosts = with pkgs.kdePackages;
        [ plasma-browser-integration ];

      profiles.default = {
        userChrome = ''
          ${css-colors}
          ${builtins.readFile ./userChrome.css}
        '';
        userContent = ''
          ${css-colors}
          ${builtins.readFile ./userContent.css}
        '';

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

        SearchEngines = {
          Add = [{
            Name = "wsh";
            URLTemplate = "http://localhost:8012/{searchTerms}";
          }];
          Default = "wsh";
          DefaultPrivate = "wsh";
          PreventInstalls = true;
        };

        ExtensionSettings = let
          nameToURL = name:
            "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
        in {
          "*".installation_mode =
            "blocked"; # blocks all addons except the ones specified below
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
              :root {
                --config-accent-color: ${accentColor};
                --config-dimmed-accent-color: ${inactiveSelected};
                --config-tinted-background: ${inactiveAccentColor};
              }
              ${builtins.readFile ./tst.css}
            '';
            
            
            configsVersion = 31;
            notifiedFeaturesVersion = 9;
            optionsExpandedGroups = [ "group-allConfigs" ];
            optionsExpandedSections = [ "section-advanced" "section-debug" ];
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
        Preferences = let
          lock-false = {
            Value = false;
            Status = "locked";
          };
          lock-true = {
            Value = true;
            Status = "locked";
          };
        in {
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
          "toolkit.legacyUserProfileCustomizations.stylesheets" = lock-true;

          #Toolbar
          "browser.uiCustomization.state" = {
            Value = ''
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
