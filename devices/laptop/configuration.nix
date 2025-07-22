{
  config,
  pkgs,
  nix-luanti,
  inputs,
  secrets,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../laptop.nix
    ../../services/remotebuild-client.nix
    ../../home/vm.nix
  ];
  boot.loader.systemd-boot.configurationLimit = 10;

  nixpkgs.config.permittedInsecurePackages = [
    #"olm-3.2.16"
  ];
  networking.firewall.enable = false;

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

  services.jellyfin.enable = false;

  #services.minetest-server.enable = true;


  virtualisation.vmware.host = {
    #enable = true;
    extraPackages = [pkgs.ntfs3g];
  };


  services.xserver.videoDrivers = [
    "modesetting"
  ];
  systemd.services.dlm.wantedBy = ["multi-user.target"];

  services.kubo = {
    enable = false;
    autoMount = true;
    localDiscovery = true;
    #extraFlags = [ "--revert-ok" ];
    package = inputs.nixpkgs-unstable.legacyPackages."x86_64-linux".kubo;
    enableGC = true;
    settings = {
      API.HTTPHeaders.Access-Control-Allow-Origin = ["*"];
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
