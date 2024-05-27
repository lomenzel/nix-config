{ config, pkgs, inputs, ... }: {
  imports = [ ./programs/firefox.nix ./programs/git.nix ./plasma.nix inputs.plasma-manager.homeManagerModules.plasma-manager ];

  home.username = "leonard";
  home.homeDirectory = "/home/leonard";
  home.stateVersion = "24.05";
}
