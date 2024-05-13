{ config, pkgs, ...}: {


  programs = with pkgs; {
    firefox = {
      enable = true;
      package = firefox-esr;
      
      profiles.default = {
        userChrome = ''
            .tabbrowser-tab {
                visibility: collapse;
            }
            .titlebar-button {
                height: 27px !important;
            }
            #nav-bar {
                margin-top: -38px;
                margin-right: 0px;
                box-shadow: none !important;
            }

            [uidensity="compact"]:root .titlebar-button {
                height: 32px !important;
            }
            [uidensity="compact"]:root #nav-bar {
                margin-top: -32px;
            }

            #titlebar-spacer {
                background-color: var(--chrome-secondary-background-color);
            }
            #titlebar-buttonbox-container {
                background-color: var(--chrome-secondary-background-color);
            }
            .titlebar-color {
                background-color: var(--toolbar-bgcolor);
            }

            #main-window[inFullscreen="true"] #sidebar-box,
            #main-window[inFullscreen="true"] #sidebar-box + splitter {
                visibility: collapse;
            }

            #sidebar-box #sidebar-header {
                display: none !important;
            }

        '';
      };

      # Check about:policies#documentation for options.
      policies = {

        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value= true;
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
        DontCheckDefaultBrowser = true;
        DisplayBookmarksToolbar = "never";
        DisplayMenuBar = "default-off";
        SearchBar = "unified"; 
      
        SearchEngines = {
          Add = [
            {
              Name = "wsh";
              URLTemplate = "http://localhost:8012/{searchTerms}";
            }
          ];
          Default = "wsh";
          DefaultPrivate = "wsh";
          PreventInstalls = true;
        };

        ExtensionSettings =
        let
            nameToURL = name: "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
        in {
          "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
          "uBlock0@raymondhill.net" = {
            install_url = nameToURL "ublock-origin";
            installation_mode = "force_installed";
          };
          "{4e507435-d65f-4467-a2c0-16dbae24f288}" = {
            install_url = nameToURL "breezedarktheme";
            installation_mode = "force_installed";
          };
          "new-tab-art@importantus.me" = {
            install_url = nameToURL "artful-tab";
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

        };

        # about:config
        Preferences = let
          lock-false = {Value = false; Status = "locked";};
          lock-true = {Value = true; Status = "locked";};
        in { 
          "widget.use-xdg-desktop-portal.file-picker" = {Value = 1; Status = "locked";};
          "browser.download.useDownloadDir" = lock-false;
          "browser.startup.homepage" = {Value = "https://menzel.lol"; Status = "locked";};
          "browser.contentblocking.category" = { Value = "strict"; Status = "locked"; };
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
                    "new-tab-art_importantus_me-browser-action",
                    "idcac-pub_guus_ninja-browser-action",
                    "ipfs-firefox-addon_lidel_org-browser-action",
                    "plasma-browser-integration_kde_org-browser-action",
                    "ublock0_raymondhill_net-browser-action",
                    "_2ea2bfef-af69-4427-909c-34e1f3f5a418_-browser-action"
                  ]
                },
                "seen":[
                  "new-tab-art_importantus_me-browser-action",
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