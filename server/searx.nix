{
  config,
  pkgs,
  secrets,
  ...
}:
{

  services.searx = {
    enable = true;
    redisCreateLocally = true;
    settings = {
      server = {
        port = 8100;
        bind_address = "0.0.0.0";
        secret_key = secrets.searx.secret;
      };
    };
  };

  services.nginx.virtualHosts."search.menzel.lol" = {
    forceSSL = true;
    useACMEHost = "wildcard";
    locations."/" = {
      proxyPass = "http://localhost:8100";
    };
  };

}
