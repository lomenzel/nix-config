{ config, pkgs, secrets, inputs, ... }: {
    
  systemd.services.deploy-uex = {
    description = "update flake and rebuild triggered by pipeline";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart =
        "export PATH=${pkgs.nixFlakes}/bin:${pkgs.git}/bin:$PATH && ${pkgs.nodejs}/bin/node ${./upServer.js}";
      Environment = [

      ];
    };
  };

  services.nginx.virtualHosts."deploy-uex.menzel.lol" = {
    forceSSL = true;
    useACMEHost = "wildcard";
    locations."/" = { proxyPass = "http://192.168.178.61:42971"; };
  };

}