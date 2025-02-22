{ config, pkgs, ...}: {

  services.location-share = {
    enable = true;
    port = 3457;
    googleApplicationCredentials = secrets.locationshare.credentials;
  };
}