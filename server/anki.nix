{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
{
  systemd.services.anki-sync-server.environment.PASSWORDS_HASHED = "1";
  services.anki-sync-server = {
    enable = true;
    users.leonard = {
      username = "leonard";
      password = secrets.anki;
    };
    port = 27701;
  };
  services.nginx.virtualHosts."anki.menzel.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:27701";
    };
  };
}
