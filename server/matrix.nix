{
  config,
  pkgs,
  secrets,
  ...
}:
let
  domain = "menzel.lol";
  baseUrl = "https://${fqdn}";
  fqdn = "matrix.${domain}";
  clientConfig."m.homeserver".base_url = baseUrl;
  serverConfig."m.server" = "${fqdn}:443";
  mkWellKnown = data: ''
    default_type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';
in
{

  services.postgresql.enable = true;
  services.postgresql.initialScript = pkgs.writeText "synapse-init.sql" ''
    CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD '${secrets.synapse-postgresql-role}';
    CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
      TEMPLATE template0
      LC_COLLATE = "C"
      LC_CTYPE = "C";
  '';

  services.matrix-synapse = {
    enable = true;
    settings = {
      server_name = domain;
      public_baseurl = baseUrl;
      registration_shared_secret = secrets.synapse-postgresql-role;
      listeners = [
        {
          port = 8008;
          bind_addresses = [ "::1" ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [
                "client"
                "federation"
              ];
              compress = true;
            }
          ];
        }
      ];
    };
  };

  services.matrix-sliding-sync = {
    enable = true;
    settings.SYNCV3_BINDADDR = "127.0.0.1:8181";
  };

  services.nginx = {
    virtualHosts = {
      "${domain}" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
          "= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
        };
      };
      "${fqdn}" = {
        enableACME = true;
        forceSSL = true;
        locations."/".extraConfig = ''
          return 404;
        '';
        locations."/_matrix".proxyPass = "http://[::1]:8008";
        # Forward requests for e.g. SSO and password-resets.
        locations."/_synapse/client".proxyPass = "http://[::1]:8008";
      };
    };
  };
  services.nginx.virtualHosts."chat.menzel.lol" = {
    enableACME = true;
    forceSSL = true;

    root = pkgs.element-web.override {
      conf = {
        default_server_config = clientConfig; # see `clientConfig` from the snippet above.
      };
    };
  };

}
