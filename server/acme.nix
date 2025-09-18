{ ... }:
{
  users.extraGroups.acme.members = [ "nginx" ];
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "leonard.menzel@tutanota.com";
      dnsPropagationCheck = false;
      dnsProvider = "inwx";
    };
    certs.wildcard.domain = "*.menzel.lol";
  };
}
