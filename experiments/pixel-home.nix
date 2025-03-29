{ pkgs, ... }:
{
  home.username = "droid";
  home.homeDirectory = "/home/droid";
  home.stateVersion = "25.05"; # To figure this out you can comment out the line and see what version it expected.
  programs.home-manager.enable = true;
  services.luanti = {
    enable = true;
    servers.default.port = 30001;
  };
}
