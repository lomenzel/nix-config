{ config, pkgs, secrets, ... }: {

  environment.systemPackages = with pkgs; [ nodejs ];

  systemd.services.json-db = {
    description = "DB for uex";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "npx --yes json-server ${pkgs.callPackage ./cookiePackage.nix { inherit pkgs; }}/db.json -p 3002";
      Environment = [

      ];
    };
  };

  systemd.services.cookie-web = {
    description = "static web for uex";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "npx --yes serve ${pkgs.callPackage ./cookiePackage.nix {inherit pkgs;}}/public -p 3001";
      Environment = [

      ];
    };
  };

  services.nginx.virtualHosts."jsondb.menzel.lol" = {
    forceSSL = true;
    useACMEHost = "wildcard";
    locations."/" = { proxyPass = "http://192.168.178.61:3002"; };
  };

  services.nginx.virtualHosts."uex.menzel.lol" = {
    forceSSL = true;
    useACMEHost = "wildcard";
    locations."/" = { proxyPass = "http://192.168.178.61:3001"; };
  };

}
