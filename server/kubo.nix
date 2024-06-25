{ config, pkgs, ... }:
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
      Addresses.API = "/ip4/0.0.0.0/tcp/5001";
      Addresses.Gateway = "/ip4/0.0.0.0/tcp/8081";
      Datastore.StorageMax = "20000GB";
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

    locations."/" = {
      proxyPass = "http://192.168.178.61:8081";
    };
  };
  services.nginx.virtualHosts."*.ipfs.gateway.menzel.lol" = {
    forceSSL = true;
    useACMEHost = "wildcardIPFS";

    locations."/" = {
      proxyPass = "http://192.168.178.61:8081";
    };
  };
  services.nginx.virtualHosts."*.ipns.gateway.menzel.lol" = {
    forceSSL = true;
    useACMEHost = "wildcardIPNS";

    locations."/" = {
      proxyPass = "http://192.168.178.61:8081";
    };
  };
}
