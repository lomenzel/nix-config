{ config
, pkgs
, inputs
, ...
}:
{
  imports = [

    ../services/wsh.nix
    ../home/home.nix
    ../server/server.nix
  ];


  fileSystems = {
    "/mnt/nfs-test" = {
      device= "192.168.178.200:/speichergruft/k3s";
      fsType= "nfs";
    };
  };
/*

  fileSystems = {
    "/mnt/snd".device = "/dev/disk/by-uuid/cdce8e60-0b76-4128-a50e-9f3c3861562e";
    "/mnt/a".device = "/dev/disk/by-uuid/3B141A01-9EFF-4832-877B-E34B4BEAA6D0";
    "/mnt/b".device = "/dev/disk/by-uuid/21CF8573-A4F2-4AD6-834B-D5BC7CA8B79A";
    "/mnt/c".device = "/dev/disk/by-uuid/147ccc9c-601b-427f-9189-8ddd948026c6";
  };

  /*
    systemd.timers.sysflake = {
       wantedBy = [ "timers.target" ];
       partOf = [ "sysflake.service" ];
       timerConfig.OnCalendar = "minutely";

     };
     systemd.services.sysflake = {
       serviceConfig.Type = "oneshot";
       script = ''
         export PATH=${pkgs.nixFlakes}/bin:${pkgs.git}/bin:$PATH
         cd /home/leonard/.config/nix-config
         nix --extra-experimental-features "nix-command flakes" flake update
        '';
     };
  */

  boot.kernelPackages = pkgs.linuxPackages_testing;

  environment.systemPackages = with pkgs; [
    helix
    rsync
  ];

  /*
    system.autoUpgrade = {
      enable = true;
      flake = "/home/leonard/.config/nix-config";
      flags = [
        "--impure"
        ];
      dates = "minutely";
    };
  */
}
