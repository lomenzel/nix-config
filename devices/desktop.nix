{ config, pkgs, inputs, ... }: {
  imports = [

    ../services/wsh.nix
    ../home/home.nix
    ../server/server.nix
  ];

  fileSystems."/mnt/snd" = {
    device = "/dev/disk/by-uuid/cdce8e60-0b76-4128-a50e-9f3c3861562e";
  };


    systemd.timers.sysflake = {
    wantedBy = [ "timers.target" ];
    partOf = [ "sysflake.service" ];
    timerConfig.OnCalendar = "minutely";

  };
  systemd.services.sysflake = {
    serviceConfig.Type = "oneshot";
    script = ''
      cd /home/leonard/.config/nix-config
      ${pkgs.nixFlakes}/bin/nix --extra-experimental-features "nix-command flakes" flake update
      ${pkgs.git}/bin/git add flake.lock
      ${pkgs.git}/bin/git commit -m "auto upgrade"
      ${pkgs.git}/bin/git push
     '';
  };


  boot.kernelPackages = pkgs.linuxPackages_testing;

  environment.systemPackages = with pkgs; [ helix rsync ];


  system.autoUpgrade = {
    enable = true;
    flake = "/home/leonard/.config/nix-config";
    flags = [
      "--impure"
      ];
    dates = "minutely";
  };
}
