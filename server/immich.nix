{ config, pkgs, ...}: {
  services.immich = {
    enable = true;
    host = "photos.menzel.lol";
    port = 8097;
  };
  services.nginx.virtualHosts."photos.menzel.lol" = {
    forceSSL = true;
    useACMEHost = "wildcard";
    locations."/" = {
      proxyPass = "http://192.168.178.61:8097";
      proxyWebsockets = true;
    };
  };

}