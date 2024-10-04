{ config, pkgs, ... }:
{

  services.jellyfin = {
    enable = true;
    dataDir = "/mnt/snd/Jellyfin/serverdata/jellyfin"
  };

  services.nginx.virtualHosts."media.menzel.lol" = {
    forceSSL = true;
    useACMEHost = "wildcard";
    locations."/" = {
      proxyPass = "http://192.168.178.61:8096";
      proxyWebsockets = true;
    };
  };
}
