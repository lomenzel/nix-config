{ config, pkgs, secrets, lib, ... }:
{

  environment.sessionVariables = {
    FLAKE = lib.mkDefault "/home/leonard/.config/nix-config";
    KUBECONFIG = secrets.k3s.kubeconfig;
  };

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes pipe-operators
    '';
    distributedBuilds = true;
  };
  users.users.leonard.packages = with pkgs; [
    nh
    htop
    curl
    killall
    nixfmt-rfc-style
    less
  ];
  users.users.leonard.shell = pkgs.zsh;
  networking.nameservers = [ "192.168.178.188" "8.8.8.8" ];
  networking.resolvconf.enable = false;

  programs.zsh = {
    enable = true;
    shellAliases = {
      up = "cd /home/leonard/.config/nix-config && git pull && nix flake update && sudo nixos-rebuild switch --flake . --impure && cd";
      ipa = "ip a | grep inet";
    };
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "direnv" ];
      theme = "jispwoso";
    };
  };
}
