{ config, pkgs, inputs, ... }:

{
  imports = [ ./shell.nix ./desktop.nix ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = { "leonard" = import ../home-manager/home.nix; };
  };

  services.xserver.enable = true;

  nix.settings.trusted-users = [ "root" "leonard" ];

  nix.sshServe.write = true;
  nix.sshServe.enable = true;

  boot.plymouth = {
    enable = true;
    logo = ./pdh_128.png;
  };

  #programs.adb.enable = true;
  programs.partition-manager.enable = true;
  #programs.steam.enable = true;

  #systemd.extraConfig = "DefaultTimeoutStopSec=5s";

  services.openssh.enable = true;

  #services.fwupd.enable = true;

  environment.sessionVariables = {
    FLAKE = "/home/leonard/.config/nix-config";
  };

  users.users.leonard = {
    isNormalUser = true;
    description = "Leonard Menzel";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker" "adbusers" ];
    packages = with pkgs; [
      nh
      #nodejs_21
      gimp
      kdePackages.elisa
      kdePackages.kmail
      kdePackages.kontact
      kdePackages.kmail-account-wizard
      kdePackages.akonadi-import-wizard
      jetbrains.webstorm
      libsForQt5.polonium
      minetest
      #glxinfo
      #clinfo
      #wayland-utils
      less
      #fwupd
      #pciutils
      #vulkan-tools
      #firefox
      kate
      htop
      curl
      tor-browser-bundle-bin
      vlc
      anki
      #git
      discord
      thunderbird
      prismlauncher
      arianna
      #kdePackages.angelfish
      signal-desktop
      libreoffice
      vscode
      killall
    ];
    shell = pkgs.zsh;
  };

}
