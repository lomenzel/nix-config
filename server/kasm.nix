{
  config,
  secrets,
  pkgs,
  ...
}:
{

  services.kasmweb = {
    enable = true;
    listenPort = 9238;
    datastorePath = "/mnt/snd/Kasmweb";
  };

  services.nginx.virtualHosts."workspaces.menzel.lol" = {
    forceSSL = true;
    useACMEHost = "wildcard";
    locations."/" = {
      proxyPass = "https://localhost:9238";
      proxyWebsockets = true;
    };
  };

}
