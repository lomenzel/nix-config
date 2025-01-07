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
    "jitsi-meet-1.0.8043"
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
          #patches = [ ./dirigera_manifest.patch ];
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

        propagatedBuildInputs = [ pkgs.python312Packages.dirigera ];

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
        trusted_proxies = [ "::1" "127.0.0.1" "192.168.178.188" ];
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
}
