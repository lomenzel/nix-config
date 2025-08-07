{
  config,
  pkgs,
  legacy_secrets,
  ...
}:
{
  services.mastodon = {
    enable = true;
    localDomain = "social.menzel.lol"; # Replace with your own domain
    configureNginx = true;
    streamingProcesses = 31;
    smtp.fromAddress = "admin@social.menzel.lol"; # Email address used by Mastodon to send emails, replace with your own
    extraConfig = {
      SINGLE_USER_MODE = "false";
      ALTERNATE_DOMAINS = "menzel.lol";

      # OIDC

      OIDC_ENABLED = "true";
      OIDC_DISPLAY_NAME = "Keycloak";
      OIDC_DISCOVERY = "true";
      OIDC_ISSUER = "https://auth.menzel.lol/realms/default";
      OIDC_SCOPE = "openid,profile,email";
      OIDC_UID_FIELD = "preferred_username";
      OIDC_REDIRECT_URI = "https://social.menzel.lol/auth/auth/openid_connect/callback";
      OIDC_SECURITY_ASSUME_EMAIL_IS_VERIFIED = "true";
      OIDC_CLIENT_ID = "mastodon";
      OIDC_CLIENT_SECRET = legacy_secrets.auth.mastodon_client_secret;
    };
  };
}
