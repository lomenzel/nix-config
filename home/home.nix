{ config, pkgs, ... }:

 {
  imports = [ ./shell.nix ./desktop.nix ./programms/firefox.nix];

  
  #programs.adb.enable = true;
  programs.partition-manager.enable = true;
  #programs.steam.enable = true;

  #systemd.extraConfig = "DefaultTimeoutStopSec=5s";

  services.openssh.enable = true;

  #services.fwupd.enable = true;



  users.users.leonard = {
    isNormalUser = true;
    description = "Leonard Menzel";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker" "adbusers" ];
    packages = with pkgs; [
      #nodejs_21
      kdePackages.elisa
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
      git
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
