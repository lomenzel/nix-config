{
  config,
  pkgs-unstable,
  lib,
  pkgs-self,
  ...
}:
{

  environment.sessionVariables = {
    NH_FLAKE = lib.mkDefault "/home/leonard/.config/nix-config";

    NIXPKGS_ALLOW_UNFREE = 1;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
    "pipe-operators"
    "recursive-nix"
    "ca-derivations"
    "dynamic-derivations"
  ];

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes pipe-operators recursive-nix ca-derivations dynamic-derivations
    '';
    distributedBuilds = true;
  };

  users.users.leonard.shell = pkgs-unstable.zsh;

  programs.zsh = {
    enable = true;
    shellAliases = {
      ipa = "ip a | grep inet";
    };
    ohMyZsh = {
      enable = true;
      plugins = [
        "git"
        "direnv"
      ];
      theme = "jispwoso";
    };
  };
}
