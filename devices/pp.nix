{ config, pkgs, ...}:

{
    imports = [

    ];

  networking.hostName = "pp";

  #
  # Opinionated defaults
  #
  
  # Use Network Manager
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;
  
  # Use PulseAudio
  hardware.pulseaudio.enable = true;
  
  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  
  # Bluetooth audio
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  
  # Enable power management options
  powerManagement.enable = true;
  
  # It's recommended to keep enabled on these constrained devices
  zramSwap.enable = true;

  # Auto-login for Plasma Mobile
  services.xserver.displayManager.autoLogin = {
    user = "leonard";
  };

  #
  # User configuration
  #

    environment.systemPackages = with pkgs; [
        vim
        wget
        git
    ];
  
  users.users."leonard" = {
    isNormalUser = true;
    description = "Leonard";
    hashedPassword = secrets.pp.password;
    extraGroups = [
      "dialout"
      "feedbackd"
      "networkmanager"
      "video"
      "wheel"
    ];
  };

    services.openssh.enable = true;


}
