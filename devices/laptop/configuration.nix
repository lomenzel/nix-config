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
    autoMount = true;
    localDiscovery = true;
    enableGC = true;
    settings = {
      Datastore.StorageMax = "200GB";
      Datastore.GCPeriod = "2h";
      Addresses.API = "/ip4/127.0.0.1/tcp/8082";
    };
  };

  system.stateVersion = "23.11";

}
