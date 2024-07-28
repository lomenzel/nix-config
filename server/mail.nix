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

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "leonard@menzel.lol" = {
        hashedPasswordFile = pkgs.writeText "mail-leonard" secrets.mail.hashedPassword;
        aliases = [ "postmaster@menzel.lol" ];
      };
    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";
  };
}
