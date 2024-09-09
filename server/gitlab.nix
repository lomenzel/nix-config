{
  config,
  pkgs,
  secrets,
  ...
}:
{
  services.gitlab = {
    enable = true;
    host = "git.menzel.lol";
    port = 443;
    https = true;
    databasePasswordFile = pkgs.writeText "password" secrets.gitlab.rootPassword;
    initialRootPasswordFile = pkgs.writeText "password" secrets.gitlab.rootPassword;
    secrets = {
      secretFile = pkgs.writeText "password" secrets.gitlab.rootPassword;
      otpFile = pkgs.writeText "password" secrets.gitlab.rootPassword;
      dbFile = pkgs.writeText "password" secrets.gitlab.rootPassword;
      jwsFile = pkgs.runCommand "oidcKeyBase" { } "${pkgs.openssl}/bin/openssl genrsa 2048 > $out";
    };
  };

  boot.kernel.sysctl."net.ipv4.ip_forward" = true; # 1
  virtualisation.docker.enable = true;
  services.gitlab-runner.enable = true;

  services.gitlab-runner.services = {
    default = {
      authenticationTokenConfigFile = pkgs.writeText "auth-file" secrets.gitlab.authenticationFile;
      dockerImage = "alpine";
    };
  };

  systemd.services.gitlab-backup.environment.BACKUP = "dump";

  services.nginx.virtualHosts."git.menzel.lol" = {
    useACMEHost = "wildcard";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
    };
  };

}
