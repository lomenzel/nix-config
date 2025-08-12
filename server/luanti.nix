{ pkgs, config, ... }:
{
  services.luanti = {
    enable = true;
    package = pkgs-unstable.luanti-server;
    servers = {
      kinder = {
        port = 30001;
        mods = with pkgs-unstable.luantiPackages.mods; [
          waypoints
        ];
        config = {
          only_peaceful_mobs = true;
        };
        whitelist = [
          "leonard"
          "airin"
          "jonas"
          "sophia"
          "stefan"
        ];
      };
      test = {
        port = 30002;
        host = "test.game.menzel.lol";
        ssl = true;
      };
    };
  };
}
