{ config, pkgs, ...}: {
    services.mastodon = {
        enable = true;
        localDomain = "social.menzel.lol"; # Replace with your own domain
        configureNginx = true;
        streamingProcesses = 31;
        smtp.fromAddress = "admin@social.menzel.lol"; # Email address used by Mastodon to send emails, replace with your own
        extraConfig.SINGLE_USER_MODE = "false";
    };
}