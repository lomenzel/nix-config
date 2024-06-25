{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{

  imports = [ ];

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.kdeconnect.enable = true;

  users.users.leonard.packages = with pkgs; [
    kdePackages.yakuake
    kdePackages.kio-gdrive
    kde-rounded-corners
    kdePackages.kaccounts-providers
    kdePackages.kaccounts-integration
    kdePackages.kcmutils
  ];

  stylix = {
    enable = true;
    image = pkgs.fetchurl {
      url = "https://github.com/AngelJumbo/gruvbox-wallpapers/blob/main/wallpapers/irl/sunforest.jpg?raw=true";
      hash = "sha256-BjGNIJIq2sg9nwk5itLY3Bz7C1jYVEVEgU3Y8KbDRNU=";
    };
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    /*
      opacity = {
        applications = 0.3;
        desktop = 0.1;
        popups = 0.1;
        terminal = 0.3;
      };
      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };
    */
    fonts = {
      monospace = {
        package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
        name = "JetBrainsMono Nerd Font Mono";
      };

    };
    targets = {
      plymouth = {
        enable = true;
        logo = pkgs.fetchurl {
          url = "https://www.pdh.eu/wp-content/uploads/PdH-Bird-Favicon-512-transparenter-Grund.png";
          hash = "sha256-TYf6MZMUzryQuGwPcxH8rGkCKd0RIOQNAPl69ADW6T8=";
        };
        logoAnimated = false;
      };
    };
  };

}
