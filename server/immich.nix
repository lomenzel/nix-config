{ config, pkgs, ... }:
{
  services.immich = {
    enable = true;
    host = "localhost";
    port = 8097;
    mediaLocation = "/var/lib/immich-data";
  };
  services.nginx.virtualHosts."photos.menzel.lol" = {
    forceSSL = true;
    useACMEHost = "wildcard";
    locations."/" = {
      proxyPass = "http://localhost:8097";
      proxyWebsockets = true;
    };
  };

}
