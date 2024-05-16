{ config, pkgs, inputs, lib, ... }: {

  imports = [


 ({config, pkgs, lib, ...}: 
 {config = lib.mkIf (config.specialisation != { }) {
    # Config that should only apply to the default system, not the specialised ones
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
    programs.kdeconnect.enable = true;

    users.users.leonard.packages = with pkgs; [
      kdePackages.yakuake
      kdePackages.kio-gdrive
      inputs.rounded-plasma.legacyPackages."x86_64-linux".kde-rounded-corners
      kdePackages.kaccounts-providers
      kdePackages.kaccounts-integration
      kdePackages.kcmutils
    ];
 };
  })
  ];



  specialisation = {
    cosmic.configuration = {
      #services.desktopManager.cosmic.enable = true;
      #services.displayManager.cosmic-greeter.enable = true;
    };
  };
}
