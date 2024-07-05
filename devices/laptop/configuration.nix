{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../laptop.nix
  ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  services.kubo = {
    enable = true;
    autoMount = false;
    localDiscovery = true;
    enableGC = true;
    settings = {
      API.HTTPHeaders.Access-Control-Allow-Origin = [ "*" ];
      API.HTTPHeaders.Access-Control-Allow-Methods = [
        "GET"
        "POST"
        "PUT"
      ];
      Datastore.StorageMax = "200GB";
      Datastore.GCPeriod = "2h";
      Addresses.API = "/ip4/127.0.0.1/tcp/8082";
      Addresses.Gateway = "/ip4/0.0.0.0/tcp/8081";

    };
  };

  system.stateVersion = "23.11";

}
