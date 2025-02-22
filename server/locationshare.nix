{ config, pkgs, secrets, ...}: {

  services.location-share = {
    enable = true;
    port = 3457;
    googleApplicationCredentials = secrets.locationshare.credentials;
    clientOrigin = "https://location.menzel.lol";
  };
}