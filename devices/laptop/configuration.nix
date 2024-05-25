{ config, pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ../laptop.nix ./spacemash.nix ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  system.stateVersion = "23.11";

}
