{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [

    ../services/wsh.nix
    ../home/home.nix
    ../server/server.nix
    ../services/remotebuild.nix
  ];

  fileSystems = {
    "/mnt/nfs-test" = {
      device = "192.168.178.200:/speichergruft/k3s";
      fsType = "nfs";
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

  #boot.kernelPackages = pkgs.linuxPackages_latest;

  environment.systemPackages = with pkgs; [
    helix
    rsync
  ];
  # programs.droidcam.enable = true;
  #  boot.extraModulePackages = with config.boot.kernelPackages; [
  #    v4l2loopback
  # ];
  # boot.extraModprobeConfig = ''
  #   options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  # '';

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    jdk
    rustup
    cargo
    rustc
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
