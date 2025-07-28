{
  config,
  pkgs,
  inputs,
  secrets,
  lib,
  pkgs-unstable,
  pkgs-stable,
  pkgs-self,
  nix-luanti,
  ...
}:
{
  imports = [
    ./programs/firefox.nix
    ./programs/git.nix
    #./programs/vim.nix
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

  home.file."${config.xdg.configHome}/speiseplan-cli/config.toml" = {
    text = ''
      url = "https://speiseplan.mcloud.digital/v2"
      language = "de"
      price_category = "student"
      location_codes = ["HL_CA", "HL_BB", "HL_ME"]
    '';
    enable = true;
  };

  programs.alacritty = {
    enable = true;
    package = pkgs-unstable.alacritty;
  };

  home.packages =
    with pkgs-unstable;
    with pkgs-unstable.kdePackages;
    [
      nh
      htop
      curl
      nix-output-monitor
      killall
      nixfmt-rfc-style
      less
      git
      exfat
      exfatprogs
      glxinfo
      clinfo
      wayland-utils
      pciutils
      vulkan-tools
      yakuake
      kio-gdrive
      kde-rounded-corners
      krfb
      krdc
      kaccounts-providers
      kaccounts-integration
      kcmutils
      maliit-keyboard
      kdepim-addons
      pimcommon
      krohnkite
      pkgs-self.vim
      inputs.speiseplan.packages."x86_64-linux".speiseplan-cli
      libreoffice
      luanti
      nixpkgs-fmt
      qtwebsockets
      brave
      picard
      mpv
      kate
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
      discord
      finamp
      kontact
      kmail-account-wizard
      akonadi-import-wizard
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
