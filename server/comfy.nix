{
  config,
  pkgs,
  secrets,
  ...
}:
{

  services.nginx.virtualHosts."comfyui.menzel.lol" = {
    forceSSL = true;
    useACMEHost = "wildcard";
    basicAuth = secrets.basicAuth;
    locations."/" = {
      proxyPass = "http://localhost:8188";
      proxyWebsockets = true;
    };
  };
}
