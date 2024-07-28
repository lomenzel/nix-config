{
  config,
  pkgs,
  secrets,
  ...
}:
let
  timeout = "120000s";
in
{
  services.kubo = {
    enable = true;
    dataDir = "/mnt/snd/ipfs";
    settings = {
      API.HTTPHeaders.Access-Control-Allow-Origin = [ "*" ];
      API.HTTPHeaders.Access-Control-Allow-Methods = [
        "GET"
        "POST"
        "PUT"
      ];
      Addresses.API = "/ip4/127.0.0.1/tcp/8082";
      Addresses.Gateway = "/ip4/0.0.0.0/tcp/8081";
      Datastore.StorageMax = "10000GB";
      Gateway = {
        PublicGateways = {
          "gateway.menzel.lol" = {
            UseSubdomains = true;
            Paths = [
              "/ipfs"
              "/ipns"
            ];
          };
        };
      };
    };
    autoMount = true;
    localDiscovery = true;
  };

  services.nginx.virtualHosts."gateway.menzel.lol" = {
    forceSSL = true;
    useACMEHost = "wildcard";

    locations."~^/(ipfs|ipns)/" = {
      proxyPass = "http://192.168.178.61:8081";
      extraConfig = ''
        proxy_read_timeout ${timeout};
        proxy_send_timeout ${timeout};
        proxy_connect_timeout ${timeout};
      '';
    };
  };
  services.nginx.virtualHosts."*.ipfs.gateway.menzel.lol" = {
    forceSSL = true;
    useACMEHost = "wildcardIPFS";

    locations."/" = {
      proxyPass = "http://192.168.178.61:8081";
      extraConfig = ''
        proxy_read_timeout ${timeout};
        proxy_send_timeout ${timeout};
        proxy_connect_timeout ${timeout};
      '';
    };
  };
  services.nginx.virtualHosts."*.ipns.gateway.menzel.lol" = {
    forceSSL = true;
    useACMEHost = "wildcardIPNS";

    locations."/" = {
      proxyPass = "http://192.168.178.61:8081";
      extraConfig = ''
        proxy_read_timeout ${timeout};
        proxy_send_timeout ${timeout};
        proxy_connect_timeout ${timeout};
      '';
    };
  };

  services.nginx.virtualHosts."ipfs.menzel.lol" = {
    forceSSL = true;
    useACMEHost = "wildcard";
    basicAuth = secrets.basicAuth;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8082";
      extraConfig = ''
        proxy_read_timeout ${timeout};
        proxy_send_timeout ${timeout};
        proxy_connect_timeout ${timeout};
      '';
    };
  };
}
