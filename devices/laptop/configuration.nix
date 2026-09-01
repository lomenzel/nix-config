{
  config,
  pkgs,
  pkgs-unstable,
  inputs,
  legacy_secrets,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    # ./persistence.nix
    # ../../services/remotebuild-client.nix
    ../../home/home.nix
    ../../modules/tailveil.nix
  ];
  networking.hostName = "laptop";

  services.tailveil = {
    enable = true;
    nodes = {
      laptop = {
        ip-address = "10.44.1.1";
        id = "VLD0:zSlM15MhSQFYx38L4JfmeF0pR8aSwbAGCU4OuJXMblQ";
      };
    };
    key = config.sops.secrets."services/tailveil/${config.networking.hostName}".path;
  };

  services.luanti.servers.test = {
    game = pkgs.luantiPackages.games.mineclone2;
    port = 30005;
    mods = [
      (pkgs.luantiPackages.mods.animalia_mcl_hunger.overrideAttrs {
        src = pkgs.fetchFromGitHub {
          owner = "tbook";
          repo = "animalia-voxelibre";
          rev = "8c2b596d516812b8191c06e55f1952e63cdc4da5";
          hash = "sha256-nf72zNHTfn/RWM+0kmAVPH420W8nkj3WGFhBMKyBO6k=";
        };
      })
    ];
  };

  networking.useDHCP = lib.mkDefault true;

  hardware.bluetooth.enable = true;
  #services.blueman.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  hardware.graphics.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "de";
    xkb.variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [
      pkgs.epson-escpr2
    ];
  };

  # 2. Enable Avahi (mDNS / Zeroconf) so network printers are automatically discovered
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # 3. (Optional but recommended) Enable scanning support for multifunction printers
  hardware.sane = {
    enable = true;
    extraBackends = [pkgs.sane-airscan];
  };

  # Make sure your user is in the printer/scanner groups
  users.users.leonard.extraGroups = ["lp" "scanner"];
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Set your time zone.
  time.timeZone = "UTC";

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

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_testing;

  programs.nix-ld.enable = false;

  services.inwx-dns.enable = false;
  services.inwx-dns.hosts = [
    "laptop.devices.lmenzel.de"
  ];

  boot.loader.systemd-boot.configurationLimit = 10;

  nixpkgs.config.permittedInsecurePackages = [
    #"olm-3.2.16"
  ];

  networking.firewall.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  nix.distributedBuilds = true;

  nixpkgs.config.nativeOptimization = "native";

  #virtualisation.docker.enable = true;

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
  systemd.services.dlm.wantedBy = ["multi-user.target"];
  networking.networkmanager.enable = true;

  security.sudo.package = pkgs.sudo.override {withInsults = true;};

  system.stateVersion = "26.05";
  nixpkgs.config.allowUnfree = true;
}
