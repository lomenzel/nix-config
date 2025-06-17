####PROXY###
users.extraGroups.acme.members = [ "nginx" ];
security.acme = {
        acceptTerms = true;
        defaults.email = "leonard.menzel@tutanota.com";
        defaults.dnsPropagationCheck = false;
};
services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;
        clientMaxBodySize = "300000m";
        virtualHosts = {
                "home.menzel.lol" = {
                        forceSSL = true;
                        enableACME = true;
                        extraConfig = ''
                                proxy_buffering off;
                        '';
                        locations."/" = {
                                proxyPass = "http://192.168.178.61:8123";
                                proxyWebsockets = true;
                        };
                };
                "cloud.menzel.lol" = {
                        forceSSL = true;
                        enableACME = true;
                        locations."/" = {
                                proxyPass = "http://192.168.178.181";
                                proxyWebsockets = true;
                        };
                        locations."~ ^/nextcloud/(?:index|remote|public|cron|core/ajax/update|status|ocs/v[12]|updater/.+|oc[ms]-provider/.+|.+/richdocumentscode/proxy).php(?:$|/)" =
        { };
                };
                "menzel.lol" = {
                        enableACME = true;
                        forceSSL = true;
                        locations = {
                                "= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
                                "= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
                                "/public" = {
                                        proxyPass = "http://192.168.178.61:8281/public";
                                };
                        };
                };
                "matrix.menzel.lol" = {
                        enableACME = true;
                        forceSSL = true;
                        locations."/".extraConfig = ''
                                return 404;
                        '';
                        locations."/_matrix".proxyPass = "http://192.168.178.61:8008";
                        # Forward requests for e.g. SSO and password-resets.
                        locations."/_synapse/client".proxyPass = "http://192.168.178.61:8008";
                        locations."/sync".proxyPass = "http://192.168.178.61:8008";
                };
                "chat.menzel.lol" = {
                        enableACME = true;
                        forceSSL = true;
                        root = pkgs.element-web.override {
                                conf = {
                                        default_server_config = clientConfig;
                                };
                        };
                };
                "photos.menzel.lol" = {
                        forceSSL = true;
                        enableACME = true;
                        locations."/" = {
                                proxyPass = "http://192.168.178.185:8097";
                                proxyWebsockets = true;
                        };
                };
                "media.menzel.lol" = {
                        forceSSL = true;
                        enableACME = true;
                        locations."/" = {
                                proxyPass = "http://192.168.178.186:8096";
                                proxyWebsockets = true;
                        };
                };
                "search.menzel.lol" = {
                        forceSSL = true;
                        enableACME = true;
                        locations."/" = {
                                proxyPass = "http://192.168.178.61:8100";
                                proxyWebsockets = true;
                        };
                };
        };
};

####NEXTCLOUD
environment.etc."nextcloud-admin-pass".text = "HBFVSOZQX";

services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud30;
        extraApps = {
                inherit (config.services.nextcloud.package.packages.apps) calendar contacts tasks;
        };
        hostName = "192.168.178.181";
        https = false;
        settings.trusted_domains = [ "192.168.178.181" "cloud.menzel.lol" ];
        config.adminpassFile = "/etc/nextcloud-admin-pass";
        home = "/mnt/nfs/nextcloud-data";
        appstoreEnable = false;
};
fileSystems."/mnt/nfs" = {
        device = "192.168.178.200:/speichergruft/k3s";
        fsType = "nfs";
};



  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    # enableACME = true;
    # forceSSL = true;
    # useACMEHost = "wildcard";
    locations = {
      "/".proxyWebsockets = true;
      "~ ^/nextcloud/(?:index|remote|public|cron|core/ajax/update|status|ocs/v[12]|updater/.+|oc[ms]-provider/.+|.+/richdocumentscode/proxy).php(?:$|/)" =
        { };
    };
  };


####IMMICH###
fileSystems."/mnt/nfs" = {
        device = "192.168.178.200:/speichergruft/k3s";
        fsType = "nfs";
};

services.immich = {
        enable = true;
        host = "0.0.0.0";
        port = 8097;
        mediaLocation = "/mnt/nfs/immich";
};

####JELLYFIN###
fileSystems."/mnt/nfs" = {
        device = "192.168.178.200:/speichergruft/k3s";
        fsType = "nfs";
};
services.jellyfin = {
        enable = true;
        dataDir = "/mnt/nfs/jellyfin";
};

