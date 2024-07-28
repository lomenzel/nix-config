{ config, pkgs ...}: {
  services = {
    samba = {
      enable = true;
      openFirewall = true;
      shares = {
        snd = {
          path = "/mnt/snd";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "leonard";
        }
      };
    };
    samba-wsdd = {
      enable = true;
      openFirewall = true;
    }
  };
  networking.firewall.allowPing = true;
}