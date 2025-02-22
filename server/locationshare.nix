{ config, pkgs, secrets, ...}: {
  services.location-share = with secrets.locationshare; {
    enable = true;
    port = 3457;
    registrationSecret = registrationSecret;
    googleApplicationCredentials =credentials;
    clientOrigin = "https://location.menzel.lol";
  };
}