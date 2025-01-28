{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../home-manager/programs/git.nix
    ../../home-manager/programs/vim.nix
  ];

  networking.nameservers = [ "192.168.178.188" "192.168.178.1" "8.8.8.8" "8.8.4.4" ];

  programs.zsh = {
    enable = true;
    shellAliases = {
      up = "cd /home/leonard/.config/nix-config && git pull && nix flake update && sudo nixos-rebuild switch --flake . --impure && cd";
      ipa = "ip a | grep inet";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "jispwoso";
    };
  };


  home.stateVersion = "24.05";
}
