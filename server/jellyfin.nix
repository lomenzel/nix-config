{ config, pkgs, ...}: {

    services.jellyfin.enable = true;
    
    services.nginx.virtualHosts."media.menzel.lol" = {
      forceSSL = true;
      useACMEHost = "wildcard";
      locations."/" = { proxyPass = "http://192.168.178.61:8096"; };
    };
}