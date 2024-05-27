{ config, pkgs, ... }: {
  imports = [ ./programs/firefox.nix ./programs/git.nix ./plasma.nix ];

  home.username = "leonard";
  home.homeDirectory = "/home/leonard";
  home.stateVersion = "24.05";
}
