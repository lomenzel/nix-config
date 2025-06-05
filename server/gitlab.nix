{
  config,
  pkgs,
  secrets,
  lib,
  ...
}:
{


  # temporary update script
  
   environment.systemPackages = [
    (let
      # XXX specify the postgresql package you'd like to upgrade to.
      # Do not forget to list the extensions you need.
      newPostgres = pkgs.postgresql_16.withPackages (pp: [
        pp.pgvecto-rs
      ]);
      cfg = config.services.postgresql;
    in pkgs.writeScriptBin "upgrade-pg-cluster" ''
      set -eux
      # XXX it's perhaps advisable to stop all services that depend on postgresql
      systemctl stop postgresql

      export NEWDATA="/var/lib/postgresql/${newPostgres.psqlSchema}"
      export NEWBIN="${newPostgres}/bin"

      export OLDDATA="${cfg.dataDir}"
      export OLDBIN="${cfg.finalPackage}/bin"

      install -d -m 0700 -o postgres -g postgres "$NEWDATA"
      cd "$NEWDATA"
      sudo -u postgres "$NEWBIN/initdb" -D "$NEWDATA" ${lib.escapeShellArgs cfg.initdbArgs}

      export PGOPTIONS='-c shared_preload_libraries=vectors'
      sudo -u postgres "$NEWBIN/pg_upgrade" \
        --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
        --old-bindir "$OLDBIN" --new-bindir "$NEWBIN" \
        "$@"
    '')
  ];
  


  services.postgresql.package = pkgs.postgresql_15;

  services.gitlab = {
   # enable = true;
    #  extraGitlabRb = ''
    #    Rails.application.config.feature_flags["activity_pub"] = true
    #    Rails.application.config.feature_flags["activity_pub_project"] = true
    #  '';
    host = "git.menzel.lol";
    port = 443;
    https = true;
    databasePasswordFile = pkgs.writeText "password" secrets.gitlab.rootPassword;
    initialRootPasswordFile = pkgs.writeText "password" secrets.gitlab.rootPassword;
    secrets = {
      activeRecordSaltFile = "/var/lib/gitlab-secrets/active_record_salt";
      activeRecordPrimaryKeyFile = "/var/lib/gitlab-secrets/active_record_primary_key";
      activeRecordDeterministicKeyFile = "/var/lib/gitlab-secrets/active_record_deterministic_key";
      secretFile = pkgs.writeText "password" secrets.gitlab.rootPassword;
      otpFile = pkgs.writeText "password" secrets.gitlab.rootPassword;
      dbFile = pkgs.writeText "password" secrets.gitlab.rootPassword;
      jwsFile = pkgs.runCommand "oidcKeyBase" { } "${pkgs.openssl}/bin/openssl genrsa 2048 > $out";
    };
  };

  boot.kernel.sysctl."net.ipv4.ip_forward" = true; # 1
  virtualisation.docker.enable = true;
  services.gitlab-runner.enable = true;

  services.gitlab-runner = {
    settings = {
      concurrent = 20;
    };
    services = {
      default = {
        authenticationTokenConfigFile = pkgs.writeText "auth-file" secrets.gitlab.authenticationFile;
        dockerImage = "alpine";
      };
      nix = with lib; {
        authenticationTokenConfigFile = pkgs.writeText "auth-file" secrets.gitlab.authenticationFileNix;
        dockerImage = "alpine";
        dockerVolumes = [
          "/nix/store:/nix/store:ro"
          "/nix/var/nix/db:/nix/var/nix/db:ro"
          "/nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:ro"
        ];
        dockerDisableCache = true;
        preBuildScript = pkgs.writeScript "setup-container" ''
          mkdir -p -m 0755 /nix/var/log/nix/drvs
          mkdir -p -m 0755 /nix/var/nix/gcroots
          mkdir -p -m 0755 /nix/var/nix/profiles
          mkdir -p -m 0755 /nix/var/nix/temproots
          mkdir -p -m 0755 /nix/var/nix/userpool
          mkdir -p -m 1777 /nix/var/nix/gcroots/per-user
          mkdir -p -m 1777 /nix/var/nix/profiles/per-user
          mkdir -p -m 0755 /nix/var/nix/profiles/per-user/root
          mkdir -p -m 0700 "$HOME/.nix-defexpr"
          . ${pkgs.nix}/etc/profile.d/nix-daemon.sh
          ${pkgs.nix}/bin/nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs # 3
          ${pkgs.nix}/bin/nix-channel --update nixpkgs
          ${pkgs.nix}/bin/nix-env -i ${
            concatStringsSep " " (
              with pkgs;
              [
                nix
                cacert
                git
                openssh
              ]
            )
          }
        '';
        environmentVariables = {
          ENV = "/etc/profile";
          USER = "root";
          NIX_REMOTE = "daemon";
          PATH = "/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/bin:/sbin:/usr/bin:/usr/sbin";
          NIX_SSL_CERT_FILE = "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt";
        };
      };
    };
  };

  systemd.services.gitlab-backup.environment.BACKUP = "dump";
  services.nginx.clientMaxBodySize = "3000m";
  services.nginx.virtualHosts."git.menzel.lol" = {
    locations."/" = {
      proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
      proxyWebsockets = true;
    };
    forceSSL = true;
    useACMEHost = "wildcard";
    extraConfig = ''
      proxy_set_header Host $host;
    '';
  };

}
