{ config, pkgs, inputs, ... }: {
  imports = [

    ../services/wsh.nix
    ../home/home.nix
    ../server/server.nix
  ];

  fileSystems."/mnt/snd" = {
    device = "/dev/disk/by-uuid/cdce8e60-0b76-4128-a50e-9f3c3861562e";
  };

  boot.kernelPackages = pkgs.linuxPackages_testing;

  environment.systemPackages = with pkgs; [ helix rsync ];


  system.autoUpgrade = {
    enable = true;
    flake = "/home/leonard/.config/nix-config";
    flags = [
      "--impure"
      "--update-input" "uex"
      ];
    dates = "minutely";
  };
}
