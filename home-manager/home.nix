{
  config,
  pkgs,
  inputs,
  secrets,
  lib,
  pkgs-unstable,
  pkgs-stable,
  nix-luanti,
  ...
}:
{
  imports = [
    ./programs/firefox.nix
    ./programs/git.nix
    ./programs/vim.nix
    inputs.nix-luanti.homeManagerModules.default
    inputs.immich-uploader.homeManagerModules.default
    #./plasma.nix
    #inputs.plasma-manager.homeManagerModules.plasma-manager
    ./programs/vscode.nix
  ];

  services.immich-upload = {
    enable = true;
    baseUrl = "https://photos.menzel.lol/api";
    apiKey = secrets.immich.apiKey;
    mediaPaths = [ "~/Bilder/Immich-Upload-Daemon-Test" ];
  };

  services.luanti = {
    enable = true;
    package = inputs.pkgs-unstable.legacyPackages."x86_64-linux".luanti-server;
    servers.test.port = 30000;
    servers.test.mods = with inputs.nix-luanti.packages."x86_64-linux".mods; [
      waypoints
    ];
    whitelist = [
      "leonard"
      "eemes"
    ];
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "olm-3.2.16"
      ];

      allowUnfreePredicate = (_: true);
    };
  };

  #home.file."${config.home.homeDirectory}/.gtkrc-2.0".force = lib.mkForce true;
  #home.file."${config.home.homeDirectory}/.librewolf/default/search.json.mozlz4".force = lib.mkForce true;

  home.packages =
    with pkgs-unstable;
    with pkgs-unstable.kdePackages;
    [

      libreoffice
      luanti
      nixpkgs-fmt
      qtwebsockets
      brave
      picard
      mpv
      kate
      tor-browser-bundle-bin
      (vlc.override {
        libbluray = libbluray.override {
          withAACS = true;
          withBDplus = true;
        };
      })
      (handbrake.override {
        libbluray = libbluray.override {
          withAACS = true;
          withBDplus = true;
        };
      })
      anki
      texliveFull
      discord
      thunderbird
      arianna
      signal-desktop
      elisa
      finamp
      alpaka
      kwallet
      kwalletmanager
      kcalc
      merkuro
      nextcloud-client
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
