{ config
, pkgs
, nix-luanti
, ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../laptop.nix
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
    "jitsi-meet-1.0.8043"
  ];
  networking.firewall.enable = false;
  services.gpsd.enable = true;



  services.udev.extraRules = ''
    # STMicroelectronics STLink V2
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="0666", GROUP="plugdev"

    # STMicroelectronics STLink V2-1
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE="0666", GROUP="plugdev"

    # STMicroelectronics STLink V3
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374f", MODE="0666", GROUP="plugdev"

    SUBSYSTEM=="tty", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE="0666", GROUP="dialout", SYMLINK+="stm32_nucleo"
  '';

  # Optional: Paket, das ST-Link und OpenOCD enthält
  # services.udev.packages = [ pkgs.openocd pkgs.stlink ];


  services.luanti = {
    enable = true;
    servers = with nix-luanti; {
      default4 = {
        game = games.mineclonia;
        port = 30007;
      };
      testing = with nix-luanti; {
        mods = with mods; [
          animalia
          i3
        ];
        port = 30001;
      };
      vanilla = {
        port = 30005;
      };
    };
  };

  fileSystems."/mnt/snd" = {
    device = "leonard@menzel.lol:/";
    fsType = "sshfs";
    options = [
      "allow_other"
      "nodev"
      "noatime"
      "IdentityFile=/home/leonard/.ssh/id_rsa"
    ];
  };

  virtualisation.vmware.host = {
    #enable = true;
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
