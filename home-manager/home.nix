{
  config,
  pkgs,
  inputs,
  secrets,
  lib,
  pkgs-unstable,
  pkgs-stable,
  pkgs-self,
  ...
}: let
  mkMenu = menu: let
    configFile = pkgs.writeText "config.yaml" (pkgs.lib.generators.toYAML {} {
      inherit menu;
    });
  in
    pkgs.writeShellScript "my-menu" ''
      exec ${lib.getExe pkgs.wlr-which-key} ${configFile}
    '';
in {
  imports = [
    ./programs/firefox.nix
    ./programs/git.nix
    ./programs/anki.nix
    ./programs/luanti.nix
    ./plasma.nix
    inputs.plasma-manager.homeModules.plasma-manager
    ./programs/wsh/default.nix
    #./programs/vim.nix
    inputs.immich-uploader.homeManagerModules.default
    #./plasma.nix
    #inputs.plasma-manager.homeManagerModules.plasma-manager
    ./programs/vscode.nix
  ];

  services.immich-upload = {
    enable = true;
    baseUrl = "https://photos.menzel.lol/api";
    apiKeyFile = secrets."services/immich/apiKey".path;
    mediaPaths = ["~/Bilder/Immich-Upload-Daemon-Test"];
  };

  services.ssh-agent.enable = true;

  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "olm-3.2.16"
      ];

      allowUnfreePredicate = _: true;
    };
  };

  home.file."${config.xdg.configHome}/speiseplan-cli/config.toml" = {
    text = ''
      url = "https://speiseplan.mcloud.digital/v2"
      language = "de"
      price_category = "student"
      location_codes = ["HL_CA", "HL_BB", "HL_ME"]
    '';
    enable = true;
  };

  home.activation = {
    removeHMBackups = lib.hm.dag.entryAfter ["writeBoundary"] ''
      rm ~/.gtkrc-2.0.homemanager-backup ~/.mozilla/firefox/default/search.json.mozlz4.homemanager-backup || true
    '';
  };

  programs.plasma = {
    enable = true;
    hotkeys.commands = {
      menu = {
        name = "Which key menu";
        key = "Meta";
        command =
          mkMenu [
            {
              key = "b";
              desc = "Browser";
              submenu = [
                {
                  key = "b";
                  desc = "Brave";
                  cmd = "${lib.getExe pkgs.brave}";
                }
                {
                  key = "c";
                  desc = "Chrome";
                  cmd = "${lib.getExe pkgs.google-chrome}";
                }
                {
                  key = "f";
                  desc = "Firefox";
                  cmd = "firefox";
                }
                {
                  key = "t";
                  desc = "Tor";
                  cmd = "${lib.getExe pkgs.tor-browser}";
                }
              ];
            }
            {
              key = "t";
              desc = "Terminal";
              cmd = "alacritty";
            }
            {
              key = "p";
              desc = "Power";
              submenu = [
                {
                  key = "a";
                  desc = "Abmelden";
                  cmd = "loginctl terminate-user leonard";
                }
                {
                  key = "s";
                  desc = "Pause";
                  cmd = "systemctl suspend";
                }
                {
                  key = "l";
                  desc = "Lock";
                  cmd = "loginctl lock-session";
                }
                {
                  key = "r";
                  desc = "Neustart";
                  cmd = "reboot";
                }
                {
                  key = "o";
                  desc = "Gute Nacht";
                  cmd = "poweroff";
                }
              ];
            }
          ]
          |> builtins.toString;
      };
    };
  };
  programs.alacritty = {
    enable = true;
    package = pkgs-unstable.alacritty;
  };

  home.packages = with pkgs-unstable;
  with pkgs-unstable.kdePackages; [
    radicle-node
    radicle-desktop
    nh
    htop
    sops
    devenv
    teamtype
    curl
    nix-output-monitor
    killall
    nixfmt
    less
    git
    mesa-demos
    mensa-sh
    clinfo
    ktorrent
    wayland-utils
    pciutils
    vulkan-tools
    darkly
    yakuake
    kio-gdrive
    appimage-run
    jujutsu
    (kde-rounded-corners.overrideAttrs (oldAttrs: {
      src = pkgs.fetchFromGitHub {
        owner = "matinlotfali";
        repo = "KDE-Rounded-Corners";
        rev = "2cf9329b31b3152e5513f7069c4bb11c765fdc6e";
        sha256 = "sha256-mVoLCnpWHC2qDouO97n2cmxiewLCokjnWl1I9tnkIN4=";
      };
    }))
    krfb
    krdc
    kaccounts-providers
    kaccounts-integration
    kcmutils
    maliit-keyboard
    kdepim-addons
    pimcommon
    krohnkite
    pkgs-self.vim
    inputs.speiseplan.packages."x86_64-linux".speiseplan-cli
    # libreoffice
    (
      luanti.withPackages {
        games = with luantiPackages.games; [
          mineclone2
          minetest_game
          nodecore
        ];
        mods = with luantiPackages.mods; [
          i3
          animalia
          logistica
        ];
        texturePacks = with luantiPackages.texturePacks; [
          (minecraft.override {
            acceptMinecraftEula = true;
          })
          soothing32
          (mergeLuantiTexturePacks [
            modrinth.tnt-barrel
            (minecraft.override {
              acceptMinecraftEula = true;
            })
          ])
        ];
      }
    )
    nixpkgs-fmt
    qtwebsockets
    brave
    picard
    fractal
    mpv
    kate
    vlc
    /*
    (handbrake.override {
      libbluray = libbluray.override {
        withAACS = true;
        withBDplus = true;
      };
    })
    */
    finamp
    kontact
    kmail-account-wizard
    akonadi-import-wizard
    kwallet
    kwalletmanager
    kcalc
    merkuro
    nextcloud-client
  ];
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  # programs.vesktop.enable = true;
  programs.starship = {
    enable = true;
  };

  #services.activitywatch.enable = true;
  home.enableNixpkgsReleaseCheck = false;
  home.username = "leonard";
  home.homeDirectory = "/home/leonard";
  home.stateVersion = "24.05";
}
