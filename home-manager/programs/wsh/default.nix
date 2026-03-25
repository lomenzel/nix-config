{ inputs, pkgs, ... }:
{
  imports = [ inputs.wsh.homeManagerModule ];
  nixpkgs.overlays = [ inputs.wsh.overlay ];
  services.wsh = {
    package = pkgs.wsh;
    enable = true;
    host_mode = "local";
    configFile = ./config.toml;
  };
}
