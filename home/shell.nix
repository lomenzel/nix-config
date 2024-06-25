{ config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    shellAliases = {
      up = "cd /home/leonard/.config/nix-config && git pull && nix flake update && sudo nixos-rebuild switch --flake . --impure && cd";
      ipa = "ip a | grep inet";
    };
    ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "jispwoso";
    };
  };
}
