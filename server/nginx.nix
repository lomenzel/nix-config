{ config, pkgs, ... }:
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    virtualHosts."*.beta.menzel.lol" = {
      forceSSL = true;
      useACMEHost = "beta-wildcard";
      locations."/" = {
        proxyPass = "https://192.168.178.169$request_uri";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };
  };
}

