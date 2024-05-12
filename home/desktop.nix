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

/*
  specialisation = {
    cosmic.configuration = {
      services.desktopManager.cosmic.enable = true;
      services.displayManager.cosmic-greeter.enable = true;
    }; 
    gnome.configuration = {
      services.xserver.displayManager.gdm.enable = true;
      services.xserver.desktopManager.gnome.enable = true;
    };
    cinnamon.configuration = {
      services.xserver.desktopManager.cinnamon.enable = true;
      services.cinnamon.apps.enable = true;
      services.xserver.displayManager.lightdm = {
        enable = true;
        greeters.slick.enable = true;
      };
    };
    hyperland.configuration = {
      imports = [ ./de/hyperland.nix ];
    };
  };
 */

}
