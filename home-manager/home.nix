{ config
, pkgs
, inputs
, pkgs-unstable
, ...
}:
{
  imports = [
    ./programs/firefox.nix
    ./programs/git.nix
    ./programs/vim.nix
    #./plasma.nix 
    #inputs.plasma-manager.homeManagerModules.plasma-manager 
    ./programs/vscode.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "olm-3.2.16"
      ];

      allowUnfreePredicate = (_: true);
    };
  };
  home.packages = with pkgs-unstable; with pkgs-unstable.kdePackages; [
    libreoffice
    luanti
    nixpkgs-fmt
    qtwebsockets
    brave
    picard
    mpv
    kate
    tor-browser-bundle-bin
    vlc
    anki
    texliveFull
    discord
    thunderbird
    arianna
    signal-desktop
    neochat
    elisa
    finamp
    itinerary
    alpaka
    kwallet
    kwalletmanager
    kcalc
    merkuro
  ];
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.starship = {
    enable = true;
  };

  #services.activitywatch.enable = true;
  home.enableNixpkgsReleaseCheck = false;
  home.username = "leonard";
  home.homeDirectory = "/home/leonard";
  home.stateVersion = "24.05";
}
