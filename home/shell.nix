{
  config,
  pkgs-unstable,
  legacy_secrets,
  lib,
  pkgs-self,
  ...
}:
{

  environment.sessionVariables = {
    NH_FLAKE = lib.mkDefault "/home/leonard/.config/nix-config";

    NIXPKGS_ALLOW_UNFREE = 1;
  };

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes pipe-operators
    '';
    distributedBuilds = true;
  };

  users.users.leonard.shell = pkgs-unstable.zsh;
  networking.nameservers = [
    "192.168.178.188"
    "8.8.8.8"
  ];
  networking.resolvconf.enable = false;

  programs.zsh = {
    enable = true;
    shellAliases = {
      up = "cd /home/leonard/.config/nix-config && git pull && nix flake update && sudo nixos-rebuild switch --flake . --impure && cd";
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
