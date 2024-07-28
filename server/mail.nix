{
  config,
  secrets,
  pkgs,
  ...
}:
{
  mailserver = {
    enable = true;
    fqdn = "mail.menzel.lol";
    domains = [ "menzel.lol" ];
    loginAccounts = {
      "leonard@menzel.lol" = {
        hashedPasswordFile = pkgs.writeText "mail-leonard" secrets.mail.hashedPassword;
        aliases = [ "postmaster@menzel.lol" ];
      };
    };
    certificateScheme = "acme-nginx";
  };
  services.roundcube = {
    enable = true;
    hostName = "mail.menzel.lol";
    configureNginx = true;
  };
}
