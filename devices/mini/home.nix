{
  pkgs,
  pkgs-native,
  config,
  inputs,
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

  home.packages = with pkgs-native; [
    #pkgs-native.rhash
    hello
    htop
    git
    curl
    home-manager
    #wget # broken
    #nix-output-monitor ghc broken
    less
    #nixfmt ghc
    vim
    #nh # broken
    fractal
    gnome-keyring
    #tuba # deno needs to build rusty_v8 from source for this to work
    passes # broken (probably some native-buildinputs vs buildinputs issue)

  ];
  services.gnome-keyring.enable = true;
  home.username = "leonard";
  home.homeDirectory = "/home/leonard";
  home.stateVersion = "26.05";
}
