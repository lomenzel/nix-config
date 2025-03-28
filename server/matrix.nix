{
  config,
  pkgs,
  secrets,
  lib,
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
  ZulipBridgeRegistrationFile = pkgs.writeText "zulip-registration.yaml" ''
    id: zulipbridge
    url: http://127.0.0.1:28464
    as_token: ${secrets.zulip-bridge.as_token}
    hs_token: ${secrets.zulip-bridge.hs_token}
    rate_limited: false
    sender_localpart: zulipbridge
    namespaces:
      users:
      - regex: '@zulip_.*'
        exclusive: true
      aliases: []
      rooms: []
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
          bind_addresses = [ "0.0.0.0" ];
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
        ZulipBridgeRegistrationFile
      ];
    };
  };

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
      /*
        appservice = {
          as_token = secrets.mautrix-signal.as_token;
          hs_token = secrets.mautrix-signal.hs_token;
        };
      */
    };
    registerToSynapse = true;
  };

  services.mx-puppet-discord = {
    enable = true;
    settings = {
      bridge = {
        bindAddress = "0.0.0.0";
        domain = "menzel.lol";
        homeserverUrl = "http://127.0.0.1:8008";
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
        address = "http://localhost:8008";
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
          "*" = "relaybot";
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

  systemd.services.matrix-zulip-bridge =
    let

      yaml = pkgs.formats.yaml { };
      settingsFile = yaml.generate "matrix-zulip-bridge.yaml" settings;
      settings = {

      };

      secretsFile = pkgs.writeText "" '''';

    in
    {
      description = "matrix-zulip-bridge - a puppeteering Matrix<->Zulip bridge";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      preStart = ''
        umask 0077
        ${lib.getExe pkgs.envsubst} -i ${settingsFile} -o ''${RUNTIME_DIRECTORY}/config.yml
      '';

      serviceConfig =
        let
          extraArgs = [ "-o @leonard:menzel.lol" ];
        in
        {
          EnvironmentFile = [ secretsFile ];
          ExecStart = "${pkgs.matrix-zulip-bridge}/bin/matrix-zulip-bridge -c ${ZulipBridgeRegistrationFile} ${lib.concatStringsSep " " extraArgs} ${baseUrl}";
          DynamicUser = true;
          StateDirectory = "matrix-zulip-bridge";
          RuntimeDirectory = "matrix-zulip-bridge";
          Restart = "on-failure";
          RestartSec = "30s";
        };
    };

  services.nginx = {
    virtualHosts = {
      /*
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
      */
      "${fqdn}" = {
        useACMEHost = "wildcard";
        forceSSL = true;
        locations."/".extraConfig = ''
          return 404;
        '';
        locations."/_matrix".proxyPass = "http://localhost:8008";
        # Forward requests for e.g. SSO and password-resets.
        locations."/_synapse/client".proxyPass = "http://localhost:8008";
        locations."/sync".proxyPass = "http://localhost:8008";
      };
    };
  };

  services.nginx.virtualHosts."chat.menzel.lol" = {
    useACMEHost = "wildcard";
    forceSSL = true;

    root = pkgs.element-web.override {
      conf = {
        default_server_config = clientConfig; # see `clientConfig` from the snippet above.
      };
    };
  };

}
