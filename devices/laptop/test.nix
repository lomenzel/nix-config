{config, pkgs, ...}:{

  systemd.timers."epg" = {
    wantedBy  = [ "timers.target"];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActivateSec = "5m";
      Unit = "epg.service";
    };
  };
  systemd.services."epg" = {
    script = ''
      echo penis
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

}