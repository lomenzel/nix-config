{ pkgs, config, ... }: {
  services = {
    hedgedoc = {
      enable = true;
      settings = {
        domain = "md.menzel.lol";
        port = 8010;
        host = "0.0.0.0";
        protocolUseSSL = true;
        allowOrigin = [
          "localhost"
          "md.menzel.lol"
        ];
      };
    };
    nginx.virtualHosts."md.menzel.lol" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:8010";
        proxyWebsockets = true;
      };
    };
  };
}