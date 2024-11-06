{ config, pkgs, ... }:
{

  services.jellyfin = {
    enable = true;
    dataDir = "/mnt/snd/Jellyfin/serverdata/jellyfin";
  };

    systemd.timers."epg" = {
    wantedBy  = [ "timers.target"];
    timerConfig = {
      OnCalendar = "daily";
    };
  };
  systemd.services."epg" = {
    script = ''
      cd /mnt/snd/Jellyfin/serverdata/epg
      ${pkgs.nodejs}/bin/npm run grab -- --site=web.magentatv.de
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "leonard";
    };
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
^