{
  config,
  pkgs-unstable,
  inputs,
  lib,
  ...
}:
let
  pkgs = pkgs-unstable;
in
{
  imports = [ ];

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.kdeconnect.enable = true;

  environment.systemPackages = with pkgs; [
    libbdplus
    libaacs
    libdvdcss
    libbluray
  ];

  stylix = {
    enable = true;
    image = pkgs.fetchurl {
      url = "https://wallpaperaccess.com/full/632832.png";
      hash = "sha256-yA0wijeakH6zLrUe4dhsqWKvZiRv3AJTnZW2QcCdTE4=";
    };
    #targets.qt.platform = lib.mkForce "gnome";
    polarity = "light";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine-dawn.yaml";

    opacity = {
      applications = 1;
      desktop = 1;
      popups = 1;
      terminal = 0.9;
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    fonts = {
      monospace = {
        package = pkgs-unstable.nerd-fonts.comic-shanns-mono;
        name = "ComicShannsMono Nerd Font Mono";
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
