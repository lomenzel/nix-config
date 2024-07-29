{ secrets, pkgs, config, ...}: {
  services = {
    keycloak = {
      enable = true;
      database = {
        type = "postgresql";
        createLocally = true;
        username = "keycloak";
        passwordFile = pkgs.writeText "keycloak-passwd" secrets.synapse-postgresql-role;
      };
      settings = {
        hostname = "menzel.lol";
        http-relative-path = "/cloak";
        http-port = 38080;
        proxy = "passthrough";
        http-enabled = true;
      };
    };
    nginx.virtualHosts."menzel.lol".locations."/cloak/" = {
      proxyPass = "http://localhost:${toString config.services.keycloak.settings.http-port}/cloak/"
    }
  }
}