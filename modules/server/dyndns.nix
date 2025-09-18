
/*

module to set dns records for a list of host names (services.inwx-dns.hosts) 
on inwx to the current ipv6 address

*/

{pkgs-self, options, config, lib, pkgs, ...}:
  let
    cfg = config.services.inwx-dns;
   in
 {

  options.services.inwx-dns = {
    enable = lib.mkEnableOption "Upload ipv6 address to inwx";
    interval = lib.mkOption {
      type = lib.types.str;
      default = "*:0/5";
      description = "interval for dyndns updates, eg. '*:0/5'";
    };
    inwx-username-file = lib.mkOption {
      type = lib.types.path;
    };
    inwx-password-file = lib.mkOption {
      type = lib.types.path;
    };
    hosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
    user = lib.mkOption {
      type = lib.types.str;
      default = "inwx-dns-update";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.timers."inwx-dns" = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = cfg.interval;
      };
    };
    systemd.services."inwx-dns" = {
      description = "Periodically update inwx dns settings for ipv6";
      environment = {
        INWX_USERNAME_FILE = cfg.inwx-username-file;
        INWX_PASSWORD_FILE = cfg.inwx-password-file;
        HOSTS_FILE = pkgs.writeText "hosts" (
          builtins.concatStringsSep "\n" cfg.hosts
        );
      };
      script = "${pkgs-self.dns-update}/bin/dns-update";
      serviceConfig = {
        Type ="oneshot";
        User = "inwx-dns-update";
      };
    };
    users = {
      groups."dns-update" = {};
      users.${cfg.user} = lib.mkDefault {
        description = "user for updating dns records";
        home = "/var/lib/${cfg.user}";
        createHome = true;
        group = "dns-update";
        isSystemUser = true;
      };
    };
  };

}