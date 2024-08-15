{
  config,
  pkgs,
  secrets,
  ...
}:
{

  imports = [ ./office.nix ];

  environment.etc."nextcloud-admin-pass".text = secrets.nextcloud.adminPassword;
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud29;
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps) calendar contacts tasks;
    };
    hostName = "cloud.menzel.lol";
    https = true;
    config.adminpassFile = "/etc/nextcloud-admin-pass";
    home = "/mnt/snd/nextcloud";
    appstoreEnable = true;
  };

  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    #enableACME = true;
    forceSSL = true;
    useACMEHost = "wildcard";
    locations = {
      "/".proxyWebsockets = true;
      "~ ^/nextcloud/(?:index|remote|public|cron|core/ajax/update|status|ocs/v[12]|updater/.+|oc[ms]-provider/.+|.+/richdocumentscode/proxy).php(?:$|/)" =
        { };
    };
  };

}
