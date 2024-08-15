{
  config,
  pkgs,
  secrets,
  lib,
  ...
}:{
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "esphone"
      "met"
      "radio_browser"
    ];
    config = {
      default_config = {};
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