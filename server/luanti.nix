{
  pkgs,
  pkgs-unstable,
  config,
  ...
}: {
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
          "Soso"
          "stefan"
        ];
      };
      sophiaLeonard = {
        port = 30002;
        mods = with pkgs-unstable.luantiPackages.mods; [
          waypoints
        ];
        game = pkgs-unstable.luantiPackages.games.mineclonia;
        config = {
          only_peaceful_mobs = false;
        };
      };
    };
  };
}
