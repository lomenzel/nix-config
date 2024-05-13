{ config, pkgs, lib, ... }: {

  imports = [

  ];

  #services.flatpak.enable = true;
  services.xserver.enable = true;

  boot.plymouth = {
    enable = true;
    logo = ./pdh_128.png;
  };
  
services.displayManager.sddm.enable = true;
        services.desktopManager.plasma6.enable = true;
        programs.kdeconnect.enable = true;

        users.users.leonard.packages = with pkgs; [
          plasma-browser-integration
          kdePackages.yakuake
          kdePackages.kio-gdrive
          kde-rounded-corners
          libsForQt5.kaccounts-providers
          libsForQt5.kaccounts-integration
          libsForQt5.kcmutils
        ];
}
