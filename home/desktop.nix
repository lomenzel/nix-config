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

  users.users.leonard.packages =
    with pkgs;
    with kdePackages;
    [
      yakuake
      kio-gdrive
      kde-rounded-corners
      krfb
      krdc
      kaccounts-providers
      kaccounts-integration
      kcmutils
      maliit-keyboard
      kdepim-addons
      pimcommon
    ];

  stylix = {
    enable = true;
    image = pkgs.fetchurl {
      url = "https://wallpaperaccess.com/full/632832.png";
      hash = "sha256-yA0wijeakH6zLrUe4dhsqWKvZiRv3AJTnZW2QcCdTE4=";
    };
    polarity = "light";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine-dawn.yaml";
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
    
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };

    };
    */
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
