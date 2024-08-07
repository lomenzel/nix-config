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
  /*
    services.gitlab-runner.services = {
      default0 = {
        # File should contain at least these two variables:
        # `CI_SERVER_URL`
        # `REGISTRATION_TOKEN`
        registrationConfigFile = pkgs.writeText "reg-file" secrets.gitlab.registrationConfigFile;
        dockerImage = "debian:stable";
        runUntagged = true;
      };
      default1 = {
        # File should contain at least these two variables:
        # `CI_SERVER_URL`
        # `REGISTRATION_TOKEN`
        registrationConfigFile = pkgs.writeText "reg-file" secrets.gitlab.registrationConfigFile;
        dockerImage = "debian:stable";
        runUntagged = true;
      };
      default2 = {
        # File should contain at least these two variables:
        # `CI_SERVER_URL`
        # `REGISTRATION_TOKEN`
        registrationConfigFile = pkgs.writeText "reg-file" secrets.gitlab.registrationConfigFile;
        dockerImage = "debian:stable";
        runUntagged = true;
      };
      default3 = {
        # File should contain at least these two variables:
        # `CI_SERVER_URL`
        # `REGISTRATION_TOKEN`
        registrationConfigFile = pkgs.writeText "reg-file" secrets.gitlab.registrationConfigFile;
        dockerImage = "debian:stable";
        runUntagged = true;
      };
      default4 = {
        # File should contain at least these two variables:
        # `CI_SERVER_URL`
        # `REGISTRATION_TOKEN`
        registrationConfigFile = pkgs.writeText "reg-file" secrets.gitlab.registrationConfigFile;
        dockerImage = "debian:stable";
        runUntagged = true;
      };
      default5 = {
        # File should contain at least these two variables:
        # `CI_SERVER_URL`
        # `REGISTRATION_TOKEN`
        registrationConfigFile = pkgs.writeText "reg-file" secrets.gitlab.registrationConfigFile;
        dockerImage = "debian:stable";
        runUntagged = true;
      };
    };
  */

  systemd.services.gitlab-backup.environment.BACKUP = "dump";

  services.nginx.virtualHosts."git.menzel.lol" = {
    useACMEHost = "wildcard";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
    };
  };

}
