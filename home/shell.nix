{ config, pkgs, secrets, ... }:
{

  environment.sessionVariables = {
    FLAKE = "/home/leonard/.config/nix-config";
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
