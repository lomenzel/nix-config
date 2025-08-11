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
    ../../services/remotebuild-client.nix
    ../../home/home.nix
    ../../services/wsh.nix
  ];

  boot.loader.systemd-boot.configurationLimit = 10;

  nixpkgs.config.permittedInsecurePackages = [
    #"olm-3.2.16"
  ];
  networking.firewall.enable = false;
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

  system.stateVersion = "23.11";
}
