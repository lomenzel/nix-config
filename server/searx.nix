{ config, pkgs, secrets, ... }:{

  services.searx = {
    enable = true;
    redisCreateLocally = true;
    settings = {
      server = {
        port = 8100;
        secret_key = secrets.searx.secret;
      };
    };
  };

  services.nginx.virtualHosts."search.menzel.lol" = {
    forceSSL = true;
    useACMEHost = "wildcard";
    locations."/" = { proxyPass = "http://192.168.178.61:8100"; };
  };


}