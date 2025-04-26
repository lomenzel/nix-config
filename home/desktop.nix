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

  environment.systemPackages = with pkgs; [
    libbdplus
    libaacs
    libdvdcss
    libbluray
  ];

  users.users.leonard.extraGroups = [ config.services.kubo.group ];
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
      krohnkite
    ];

  stylix = {
    enable = true;
    image = pkgs.fetchurl {
      url = "https://wallpaperaccess.com/full/632832.png";
      hash = "sha256-yA0wijeakH6zLrUe4dhsqWKvZiRv3AJTnZW2QcCdTE4=";
    };
    targets.qt.platform = "kde6";
    polarity = "light";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine-dawn.yaml";

    opacity = {
      applications = 0.5;
      desktop = 0.5;
      popups = 0.5;
      terminal = 0.5;
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    fonts = {
      monospace = {
        package = inputs.pkgs-unstable.legacyPackages."x86_64-linux".nerd-fonts.jetbrains-mono;
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
