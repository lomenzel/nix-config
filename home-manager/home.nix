{ config, pkgs, ...}:
{
    imports = [ 
        ./programs/firefox.nix 
    ];

    home.username = "leonard";
    home.homeDirectory = "/home/leonard";
    home.stateVersion = "24.05";
}