{
  config,
  pkgs,
  secrets,
  inputs,
  ...
}:
let
  startScript = pkgs.writeShellScriptBin "start-uex-deploy-server" ''
    export PATH=${pkgs.nixos-rebuild}/bin:${pkgs.nodejs}/bin:${pkgs.nixFlakes}/bin:${pkgs.git}/bin:$PATH
    node ${./upServer.js}
  '';
in
{

  systemd.services.deploy-uex = {
    description = "update flake and rebuild triggered by pipeline";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${startScript}/bin/start-uex-deploy-server";
    };
  };

  services.nginx.virtualHosts."deploy-uex.menzel.lol" = {
    forceSSL = true;
    useACMEHost = "wildcard";
    locations."/" = {
      proxyPass = "http://192.168.178.61:42971";
    };
  };

}
