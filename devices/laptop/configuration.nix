{ config, pkgs, ... }:{
  imports = [
    ./hardware-configuration.nix
    ../laptop.nix
  ];


 nix = {
  package = pkgs.nixFlakes;
  extraOptions = ''
    experimental-features = nix-command flakes
  '';
};

services.cron = {
  enable = false;
  systemCronJobs = [
    "* * * * * root /etc/nixos/cronup.sh"
  ];
};

  system.stateVersion = "23.11";

}
