# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  nix-luanti,
  ...
}:
let
  toHostList =
    virtualHosts:
    builtins.concatStringsSep "\n" (
      builtins.map (hostname: "127.0.0.1 ${hostname}") (builtins.attrNames virtualHosts)
    );
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    #../../services/samba.nix
    ../../server/overleaf.nix
  ];
    # overleaf
  services.overleaf = {
    enable = true;
    dataDir = "/var/lib/overleaf";
    port = "8083";
    forceBuild = true;
  };


  services.luanti = {
    enable = true;
    package = inputs.nixpkgs-unstable.legacyPackages."x86_64-linux".luanti-server;
    servers.kinder = {
      port = 30001;
      mods = with nix-luanti.mods; [
        waypoints
      ];
      config = {
        only_peaceful_mobs = true;
      };
      whitelist = [
        "leonard"
        "airin"
        "jonas"
        "sophia"
        "stefan"
      ];
    };

    servers.airin = {
      port = 30002;
      config.only_peaceful_mobs = true;
      whitelist = [
        "leonard"
        "airin"
      ];
    };
  };

  fileSystems."/mnt/server" = {
    device = "192.168.178.188:/var/lib/nfs/desktop";
    fsType = "nfs4";
    options = [
      "defaults"
      "_netdev"
    ];
  };

  hardware.bluetooth.enable = true;
  #services.blueman.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
    "jitsi-meet-1.0.8043"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "desktop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking = {
    networkmanager.enable = true;
    #nameservers = [ "192.168.178.21" ];
    #extraHosts = toHostList config.services.nginx.virtualHosts;
  };

  #services.blueman.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ nvidia-vaapi-driver ];
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];
  #hardware.nvidia-container-toolkit.enable = true;
  hardware.nvidia = {

    #   # Modesetting is required.
    #   modesetting.enable = false;
    #   powerManagement.enable = false;
    #   powerManagement.finegrained = false;

    open = false;

    #   nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  services.xserver.enable = true;

  services.xserver = {
    xkb.layout = "de";
    xkb.variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

  };

  users.users.leonard = {
    isNormalUser = true;
    description = "Leonard Menzel";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    #vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
  ];

  services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  #services.teamviewer.enable = true;

  /*
    services.wyoming.satellite = {
      area = "Stübele";
      enable = true;
      sounds = {
        awake = ./marimba-bloop-2-188149.wav;
        done = ./marimba-bloop-3-188151.wav;
      };
      vad.enable = false;
      user = "leonard";
      microphone.command = "${pkgs.pulseaudio}/bin/parec -d alsa_input.usb-C-Media_Electronics_Inc._USB_PnP_Sound_Device-00.mono-fallback --raw --rate=16000 --format=s16le --channels=1";
    };
    services.wyoming.openwakeword = {
      preloadModels = [ "hey_jarvis" ];
      enable = true;
    };
  */

}
