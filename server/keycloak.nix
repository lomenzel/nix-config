{
  secrets,
  pkgs,
  config,
  ...
}:
{
  services = {
    keycloak = {
      enable = true;
      database = {
        type = "postgresql";
        createLocally = true;
        username = "keycloak";
        passwordFile = "${pkgs.writeText "keycloak-passwd" secrets.synapse-postgresql-role}";
      };
      settings = {
        hostname = "accounts.menzel.lol";
        http-relative-path = "/";
        http-port = 38080;
        proxy-headers = "forwarded";
        http-enabled = true;
      };
    };
    nginx.virtualHosts."accounts.menzel.lol" = {
      forceSSL = true;
      useACMEHost = "wildcard";
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.keycloak.settings.http-port}/";
        extraConfig = ''
          add_header Content-Security-Policy "frame-src 'self' https://menzel.lol;";
        '';
      };
    };
  };
}
