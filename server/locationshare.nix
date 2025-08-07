{
  config,
  pkgs,
  legacy_secrets,
  ...
}:
{
  services.location-share = with legacy_secrets.locationshare; {
    enable = true;
    port = 3457;
    registrationSecret = registrationSecret;
    googleApplicationCredentials = credentials;
    clientOrigin = "https://location.menzel.lol";
  };
}
