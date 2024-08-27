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
      "esphome"
      "met"
      "radio_browser"
      "google_translate"
      "google_assistant"
      "jellyfin"
      "ollama"
      "habitica"
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
    ];
    customComponents = [
      (pkgs.buildHomeAssistantComponent rec {

        owner = "sanjoyg";
        domain = "dirigera_platform";
        version = "1.7.12";

        src = pkgs.fetchFromGitHub {
          inherit owner;
          repo = "dirigera_platform";
          rev = version;
          hash = "sha256-fi7QNgFpg1hghT7ce890OUu+VnzZodytk7vGaUmuiXg=";
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
        server_host = "::1";
        trusted_proxies = [ "::1" ];
        use_x_forwarded_for = true;
      };
      "automation ui" = "!include automations.yaml";
      "scene ui" = "!include scenes.yaml";
    };
  };

  services.nginx.virtualHosts."home.menzel.lol" = {
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      proxy_buffering off;
    '';
    locations."/" = {
      proxyPass = "http://[::1]:8123";
      proxyWebsockets = true;
    };
  };
}