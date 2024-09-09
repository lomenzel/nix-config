{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../server/pihole.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "pi"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "UTC";

  i18n.defaultLocale = "de_DE.UTF-8";
  console = {
    enable = false;
  };

  services.printing.enable = true;

  users.users.leonard = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      #firefox
      # tree
      tldr
      #git
      neofetch
      gtop
      #dvdbackup
    ];
    shell = pkgs.zsh;
  };

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      up = "sudo nix-channel --update && sudo nixos-rebuild switch";
      ur = "sudo nix-channel --update && sudo nixos-rebuild boot && sudo reboot";
      conf = "sudo vim /etc/nixos/configuration.nix";
    };
    ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "jispwoso";
    };
  };

  fileSystems."/mnt/lv" = {
    device = "dev/sda1";

  };

  services.kubo = {
    enable = true;
    autoMount = true;
    dataDir = "/mnt/lv/ipfs";
    settings = {
      API = {
        HTTPHeaders = {
          Access-Control-Allow-Origin = [ "*" ];
          Access-Control-Allow-Methods = [
            "GET"
            "POST"
            "PUT"
          ];
        };
      };
      Addresses.API = "/ip4/0.0.0.0/tcp/5001";
      Datastore.StorageMax = "1700GB";
    };

  };

  #services.jellyfin.enable = true;
  #services.hedgedoc.enable = true;

  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    libraspberrypi
    raspberrypi-eeprom
    #git
  ];

  security.sudo.package = pkgs.sudo.override { withInsults = true; };

  nixpkgs.config.allowUnfree = true;

  services.openssh.enable = true;

  networking.firewall.enable = false;
  #system.copySystemConfiguration = true;

}
