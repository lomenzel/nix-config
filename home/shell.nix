{ config, pkgs, ... }:
{

  environment.sessionVariables = {
    FLAKE = "/home/leonard/.config/nix-config";
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes 
    '';
    distributedBuilds = true;
  };
  users.users.leonard.packages = with pkgs; [nh htop curl killall nixfmt-rfc-style less];
  users.users.leonard.shell = pkgs.zsh;
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
