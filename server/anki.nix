{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
{
  #systemd.services.anki-sync-server.environment.PASSWORDS_HASHED = "1";
  services.anki-sync-server = {
    enable = true;
    users = [
      {
        username = "leonard";
        password = secrets.anki;
      }
    ];
    port = 27701;
    address = "0.0.0.0";
  };
  services.nginx.virtualHosts."anki.menzel.lol" = {
    useACMEHost = "wildcard";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:27701";
    };
  };
}
