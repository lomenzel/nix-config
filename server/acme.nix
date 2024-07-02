{
  config,
  pkgs,
  secrets,
  ...
}:

let
  inwxCredentials = pkgs.writeText "inwx-credentials" secrets.acme.inwxCredentials;
in
{

  users.extraGroups.acme.members = [ "nginx" ];
  security.acme = {
    acceptTerms = true;
    defaults.email = "leonard.menzel@tutanota.com";
    defaults.dnsPropagationCheck = false;

    certs = {
      "wildcard" = {
        domain = "*.menzel.lol";
        #listenHTTP = ":80";
        dnsProvider = "inwx";
        credentialsFile = inwxCredentials;
      };
      "wildcardIPFS" = {
        domain = "*.ipfs.gateway.menzel.lol";
        #listenHTTP = ":80";
        dnsProvider = "inwx";
        credentialsFile = inwxCredentials;
      };
      "wildcardIPNS" = {
        domain = "*.ipns.gateway.menzel.lol";
        #listenHTTP = ":80";
        dnsProvider = "inwx";
        credentialsFile = inwxCredentials;
      };
      "ai-wildcard" = {
        domain = "*.ai.menzel.lol";
        dnsProvider = "inwx";
        credentialsFile = inwxCredentials;
      };
      /*
        "turn.menzel.lol" = {
          # TODO
          dnsProvider = "inwx";
          credentialsFile = inwxCredentials;

          postRun = "systemctl restart coturn.service";
          group = "turnserver";
        };
      */
    };
  };
}
