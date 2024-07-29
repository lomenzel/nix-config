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
        hostname = "keycloak.menzel.lol";
        http-relative-path = "/";
        http-port = 38080;
        proxy = "edge";
        http-enabled = true;
      };
    };
    nginx.virtualHosts."keycloak.menzel.lol" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.keycloak.settings.http-port}/";
        extraConfig = ''
          add_header Content-Security-Policy "frame-src 'self' https://menzel.lol;";
        '';
      };
    };
  };
}
