{ config, pkgs, secrets, ... }: {

  environment.systemPackages = with pkgs; [ nodejs ];

  systemd.services.json-db = {
    description = "DB for uex";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "npx --yes json-server /home/leonard/Projekte/CookieDB -p 3002";
      Environment = [

      ];
    };
  };

    services.cron = {
    enable = true;
    systemCronJobs = [ "* * * * * ${./cookieCron.sh}"];
  };




  services.nginx.virtualHosts."jsondb.menzel.lol" = {
    forceSSL = true;
    useACMEHost = "wildcard";
    locations."/" = { proxyPass = "http://192.168.178.61:3002"; };
  };

  services.nginx.virtualHosts."uex.menzel.lol" = {
    forceSSL = true;
    useACMEHost = "wildcard";
    root = "${pkgs.callPackage ./cookiePackage.nix {inherit pkgs;}}/public";
  };

}
