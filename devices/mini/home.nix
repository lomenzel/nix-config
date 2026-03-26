{
  pkgs,
  pkgs-native,
  config,
  inputs,
  vim-config,
  ...
}:
{
  imports = [
    ../../home-manager/programs/wsh/default.nix
    # (
    #   { pkgs, ... }@args:
    #   ((import ../../home-manager/programs/anki.nix) (args // { secrets = config.sops.secrets; }))
    # )
    #inputs.sops-nix.homeManagerModules.sops
  ];

/*
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "home/.config/sops/keys/age-key.txt";
    secrets = {
      "programs/anki/sync_key" = { };
      "services.immich/apiKey" = { };
    };
  };
*/

  home.packages = with pkgs; [
    htop
    git
    curl
    home-manager
    mensa-sh
    #jellyfin-desktop # unsupported system / mpvqt native vs buildinputs
    #gnome-contacts # broken dependency
    #vim-config broken
    #wget # broken
    #nix-output-monitor ghc broken
    #nixfmt broken
    vim
    #nh # broken
    fractal
    gnome-keyring
    appimage-run
    #firefox-mobile # broken dependency
    tuba
    luanti
    passes
    gnome-clocks
    gnome-weather
    gnome-calculator
    epiphany
    gnome-chess
    gnome-console
  ];

  xdg.configFile."environment.d/nix-gpu.conf".text = ''
    MESA_GLES_VERSION_OVERRIDE=2.0
    LIBGL_DRIVERS_PATH=/usr/lib/dri
    LIBVA_DRIVERS_PATH=/usr/lib/dri
    __EGL_VENDOR_LIBRARY_DIRS=/usr/share/glvnd/egl_vendor.d
  '';

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
      ];
      theme = "jispwoso";
    };
  };
  targets.genericLinux.enable = true;
  targets.genericLinux.gpu.enable = false;
  xdg.enable = true;
  services.gnome-keyring.enable = true;
  home.username = "leonard";
  home.homeDirectory = "/home/leonard";
  home.stateVersion = "26.05";
}
