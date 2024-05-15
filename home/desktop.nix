{ config, pkgs, lib, ... }: {

  imports = [

  ];


  config = lib.mkIf (config.specialisation != { }) {
    # Config that should only apply to the default system, not the specialised ones
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
  };

  config.specialisation = {
    cosmic.configuration = {
      services.desktopManager.cosmic.enable = true;
      services.displayManager.cosmic-greeter.enable = true;
    };
  };
}
