{ config, pkgs, ... }:{
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

  programs.neovim = {
    enable = true;
    configure = { customRC = "	set number\n	set autowriteall\n"; };
    vimAlias = true;
    viAlias = true;
  };
}
