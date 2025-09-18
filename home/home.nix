{
  config,
  pkgs,
  inputs,
  lib,
  helper-functions,
  pkgs-unstable,
  pkgs-stable,
  pkgs-self,
  ...
}:

{
  imports = [
    ./shell.nix
    ./desktop.nix
  ];

  home-manager = {
    extraSpecialArgs = {
      inherit
        inputs
        helper-functions
        pkgs-unstable
        pkgs-stable
        pkgs-self
        ;
      secrets = config.sops.secrets;
    };
    users = {
      "leonard" = import ../home-manager/home.nix;
    };
    backupFileExtension = "homemanager-backup";
  };

  services.xserver.enable = true;

  nix.settings.trusted-users = [
    "root"
    "leonard"
  ];

  boot.plymouth = {
    enable = true;
  };

  programs.adb.enable = true;
  programs.partition-manager.enable = true;

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  programs.ausweisapp.enable = true;
  programs.ausweisapp.openFirewall = true;

  services.openssh.enable = true;
  services.fwupd.enable = true;
  xdg.portal.enable = true;

  users.users.leonard = {
    isNormalUser = true;
    description = "Leonard Menzel";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "docker"
      "adbusers"
      "dialout"
      "plugdev"
    ];
  };

}
