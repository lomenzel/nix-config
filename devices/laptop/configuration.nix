{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../laptop.nix
    #./test.nix
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
    "jitsi-meet-1.0.8043"
  ];
  networking.firewall.enable = false;

  fileSystems."/mnt/snd" = {
    device = "leonard@menzel.lol:/mnt/snd";
    fsType = "sshfs";
    options = [
      "allow_other"
      "nodev"
      "noatime"
      "IdentityFile=/home/leonard/.ssh/id_rsa"
    ];
  };

  virtualisation.vmware.host = {
    enable = true;
    extraPackages = [ pkgs.ntfs3g ];
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
