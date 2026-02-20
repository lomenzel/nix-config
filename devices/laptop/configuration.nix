{
  config,
  pkgs,
  pkgs-unstable,
  inputs,
  legacy_secrets,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
   # ./persistence.nix
    ../../services/remotebuild-client.nix
    ../../home/home.nix
    ../../services/wsh

  ];

  boot.kernelPackages = pkgs.linuxPackages_testing;

  programs.nix-ld.enable = false;

  services.inwx-dns.enable = false;
  services.inwx-dns.hosts = [
    "laptop.devices.lmenzel.de"
  ];
  services.nginx = {
    enable = true;
    virtualHosts."laptop.devices.lmenzel.de" = {
      forceSSL = false;
      locations."/" = {
        extraConfig = ''
          add_header Content-Type text/plain;
          return 200 "laptop is online\n";
        '';
      };
    };
  };

  services.luanti.servers = {
    wiefaewiubguazb = {
      port = 30000;
      mapserver = {
        enable = true;
        companionMod = true;
        config = {
          port = 30001;
          webapi.secretkey = "supersecret";
        };
      };
      game = pkgs-unstable.luantiPackages.games.mineclonia;
      config = {
        mcl_villages_village_chance = 300;
      };
      host = "game.localhost";
    };
  };

  boot.loader.systemd-boot.configurationLimit = 10;

  nixpkgs.config.permittedInsecurePackages = [
    #"olm-3.2.16"
  ];

  networking.firewall.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  nix.distributedBuilds = true;

  nixpkgs.config.nativeOptimization = "native";

  virtualisation.docker.enable = true;

  services.udev.extraRules = ''
    # STMicroelectronics STLink V2
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="0666", GROUP="plugdev"

    # STMicroelectronics STLink V2-1
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE="0666", GROUP="plugdev"

    # STMicroelectronics STLink V3
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374f", MODE="0666", GROUP="plugdev"

    SUBSYSTEM=="tty", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE="0666", GROUP="dialout", SYMLINK+="stm32_nucleo"
  '';

  services.xserver.videoDrivers = [
    "modesetting"
  ];
  systemd.services.dlm.wantedBy = [ "multi-user.target" ];

  system.stateVersion = "25.05";
}
