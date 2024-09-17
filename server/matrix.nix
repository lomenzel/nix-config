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
      use_appservice_legacy_authorization = true;
      enableRegistrationScript = false;
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
      app_service_config_files = [
        "/var/lib/matrix-synapse/telegram-registration.yaml"
        "/var/lib/matrix-synapse/discord-registration.yaml"
      ];
    };
  };

  /*
    services.matrix-sliding-sync = {
      enable = true;
      settings = {
        SYNCV3_BINDADDR = "127.0.0.1:8181";
        SYNCV3_SERVER = "http://127.0.0.1:8008";
        SYNCV3_DB = "postgres://matrix-synapse:${secrets.synapse-postgresql-role}@localhost/matrix-synapse";
        SYNCV3_SECRET = secrets.syncv3-secret;
      };
      environmentFile = "${pkgs.writeText "matrix-sliding-sync.env" ''
        # SYNCV3_BINDADDR=127.0.0.1:8181
        # Add any additional environment variables needed for matrix-sliding-sync here
      ''}";
    };
  */

  # bridges

  services.mautrix-signal = {
    enable = true;
    settings = {
      homeserver.address = "http://localhost:8008";
      bridge = {
        history_sync.request_full_sync = true;
        mute_bridging = true;
        permissions."menzel.lol" = "user";
        private_chat_portal_meta = true;
      };
      encryption = {
          allow = true;
          default = true;
          pickle_key = secrets.mautrix-signal.key;
      };
      appservice = {
        as_token = secrets.mautrix-signal.as_token;
        hs_token = secrets.mautrix-signal.hs_token;
      };
    };
    registerToSynapse = true;
  };

  services.mx-puppet-discord = {
    enable = true;
    settings = {
      bridge = {
        bindAddress = "0.0.0.0";
        domain = "menzel.lol";
        homeserverUrl = "http://localhost:8008";
      };
      logging.console = "silly";
      provisioning.whitelist = [ "@leonard:menzel.lol" ];
      relay.whitelist = [ "@.*:menzel.lol" ];
    };
  };

  services.mautrix-whatsapp = {
    enable = true;
    settings = {
      appservice = {
        as_token = secrets.mautrix-whatsapp.as_token;
        hs_token = secrets.mautrix-whatsapp.hs_token;
      };
      homeserver.address = "http://localhost:8008";
      bridge = {
        encryption = {
          allow = true;
          default = true;
        };
        history_sync.request_full_sync = true;
        mute_bridging = true;
        permissions."menzel.lol" = "user";
        private_chat_portal_meta = true;
      };
    };
  };

  services.mautrix-telegram = {
    enable = true;

    settings = {
      homeserver = {
        address = "http://[::1]:8008";
        domain = "menzel.lol";
      };
      appservice = {
        provisioning.enable = false;
        id = "telegram";
        public = {
          enabled = true;
          prefix = "/public";
          external = "https://menzel.lol/public";
        };
        as_token = secrets.mautrix-telegram.as_token;
        hs_token = secrets.mautrix-telegram.hs_token;
        port = 8281;
        address = "http://localhost:8281";
      };
      bridge = {
        relaybot.authless_portals = false;
        permissions = {
          "@leonard:menzel.lol" = "admin";
        };
        animated_sticker = {
          target = "webm";
          args = {
            width = 256;
            height = 256;
            fps = 30;
          };
        };
      };
      telegram = {
        api_id = secrets.mautrix-telegram.id;
        api_hash = secrets.mautrix-telegram.hash;
      };
    };
  };
  systemd.services.mautrix-telegram.path = [ pkgs.ffmpeg ]; # converting stickers

  services.nginx = {
    virtualHosts = {
      "${domain}" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
          "= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
          "/public" = {
            proxyPass = "http://localhost:8281/public";
          };
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
