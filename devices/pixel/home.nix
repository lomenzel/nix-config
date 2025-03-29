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
