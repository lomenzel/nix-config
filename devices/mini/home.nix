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
    mensa-sh-gnome
    #jellyfin-desktop # unsupported system
    #vim-config broken
    #wget # broken
    #nix-output-monitor ghc broken
    less
    #nixfmt broken
    vim
    #nh # broken
    fractal
    gnome-keyring
    #firefox-mobile # broken dependency
    #tuba # deno needs to build rusty_v8 from source for this to work
    passes # broken (probably some native-buildinputs vs buildinputs issue)

  ];

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
