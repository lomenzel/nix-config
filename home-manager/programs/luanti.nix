{pkgs, config, lib,inputs, ...}: {

  imports = [inputs.nix-luanti.homeManagerModules.default];
  services.luanti.servers.anarna = with pkgs.luantiPackages; {
    enable = false;
    game = games.mineclonia;
    port = 30100; # Specifies the server port
    mods = with pkgs.luantiPackages.mods; [
      waypoints
    ];
    config = {
      only_peaceful_mobs = true;
    };
  };
}