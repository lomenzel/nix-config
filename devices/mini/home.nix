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

  home.packages = with pkgs; [
    hello
    htop

    #pkgs-native.hello
    #fractal
    #tuba
    #passes
    #nh

  ];
  home.username = "leonard";
  home.homeDirectory = "/home/leonard";
  home.stateVersion = "26.05";
}
