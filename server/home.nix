{
  config,
  pkgs,
  secrets,
  lib,
  ...
}:
{

  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

  services.matter-server.enable = true;
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "default_config"
      "bluetooth_tracker"
      "bluetooth_le_tracker"
      "bluetooth"
      "esphome"
      "met"
      "radio_browser"
      "google_translate"
      "google_assistant"
      "jellyfin"
      "ollama"
      "habitica"
      "thermopro"
      #"matrix"
      "pi_hole"
      "matter"
      "home_connect"
      "epson"
      "caldav"
      "nextcloud"
      "mastodon"
      "minecraft_server"
      "github"
      "gitlab_ci"
      "hue"
      "switchbot"
      "fritzbox"
      "fritzbox_callmonitor"
      "fritz"
      "adguard"
      "whisper"
      "piper"
      "wyoming"
    ];
    customComponents = [
      (pkgs.buildHomeAssistantComponent rec {
        owner = "sudoxnym";
        domain = "saas";
        version = "0.1.0";
        src = pkgs.fetchFromGitHub {
          inherit owner;
          repo = domain;
          rev = version;
          hash = "sha256-eFagGzVekRIEGPdONEBVbiYufjelkpoUiepbqMTZV84=";
        };
      })
      (pkgs.buildHomeAssistantComponent rec {

        owner = "sanjoyg";
        domain = "dirigera_platform";
        version = "2.6.4";

        src = pkgs.stdenv.mkDerivation {
          pname = "patched-dirigera-platform";
          version = "2.6.4";
          patches = [ ./dirigera_manifest.patch ];
          src = pkgs.fetchFromGitHub {
            inherit owner;
            repo = "dirigera_platform";
            rev = version;
            hash = "sha256-ftJUmJ5UWgm22YBfCIBAxRjG+niougw5ekrQNuSRgzI=";
          };
          installPhase = ''
            mkdir -p $out
            cp -r ./* $out
          '';
        };

        propagatedBuildInputs = [ pkgs.python313Packages.dirigera ];

        meta = {
          description = "HomeAssistant integration for derigera";
          homepage = "https://github.com/sanjoyg/dirigera_platform";
          license = lib.licenses.mit;
        };
      })
    ];

    config = {
      default_config = { };
      http = {
        server_host = "0.0.0.0";
        trusted_proxies = [
          "::1"
          "127.0.0.1"
          "192.168.178.188"
        ];
        use_x_forwarded_for = true;
      };
      "automation ui" = "!include automations.yaml";
      "scene ui" = "!include scenes.yaml";
    };
  };

  services.nginx.virtualHosts."home.menzel.lol" = {
    #forceSSL = true;
    #enableACME = true;
    extraConfig = ''
      proxy_buffering off;
    '';
    locations."/" = {
      proxyPass = "http://localhost:8123";
      proxyWebsockets = true;
    };
  };

  services.wyoming = {
    faster-whisper.servers.test = {
      enable = true;
      device = "cuda";
      language = "de";
      uri = "tcp://0.0.0.0:10300";
    };
    piper.servers.test = {
      enable = true;
      uri = "tcp://0.0.0.0:10200";
      voice = "de_DE-thorsten-high";
    };
  };

  services.esphome.enable = true;
  services.esphome.openFirewall = true;

  nixpkgs.config.cudaSupport = true;
  nix.settings.substituters = [
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    # Compare to the key published at https://nix-community.org/cache
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
}
