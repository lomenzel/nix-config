{ config, pkgs, ...}: {
  services.immich = {
    enable = true;
    host = "photos.menzel.lol";
  };
}