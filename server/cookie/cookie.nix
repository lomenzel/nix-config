{
  config,
  pkgs,
  secrets,
  uex,
  
}:

{

  imports = [ ./update.nix ];
  systemd.timers.cookieBackup = {
    wantedBy = [ "timers.target" ];
    partOf = [ "cookieBackup.service" ];
    timerConfig.OnCalendar = "minutely";

  };
  systemd.services.cookieBackup = {
    serviceConfig.Type = "oneshot";
    script = ''
      cd /home/leonard/Projekte/CookieDB

      # Timestamp in die Log-Datei schreiben
      echo "$(date): Starting systemd timer" >> /home/leonard/Projekte/CookieDB/cron.log


      # Git-Befehle ausführen
      ${pkgs.git}/bin/git add db.json >> /home/leonard/Projekte/CookieDB/cron.log 2>&1
      ${pkgs.git}/bin/git commit -m "new data" --author="Server <desktop@menzel.lol>" >> /home/leonard/Projekte/CookieDB/cron.log 2>&1
      ${pkgs.git}/bin/git push >> /home/leonard/Projekte/CookieDB/cron.log 2>&1
    '';
  };

  systemd.services.json-db = {
    description = "DB for uex";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.nodePackages.json-server}/bin/json-server /home/leonard/Projekte/CookieDB/db.json -p 3002";
      Environment = [

      ];
    };
  };

  services.nginx.virtualHosts."jsondb.menzel.lol" = {
    forceSSL = true;
    useACMEHost = "wildcard";
    locations."/" = {
      proxyPass = "http://192.168.178.61:3002";
    };
  };

  services.nginx.virtualHosts."uex.menzel.lol" = {
    forceSSL = true;
    useACMEHost = "wildcard";
    basicAuth = secrets.cookie.basicAuth;
    root = "${uex.packages.x86_64-linux.default}/public";
  };

}
