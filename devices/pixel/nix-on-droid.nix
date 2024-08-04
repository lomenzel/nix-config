{
  config,
  lib,
  pkgs,
  ...
}:
{

  #imports = [ ../../home/shell.nix ];
  environment.packages = with pkgs; [ ];
  environment.etcBackupExtension = ".bak";
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  time.timeZone = "UTC";

  home-manager = {
    config = ./home.nix;
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
  };

  android-integration = {
    termux-open.enable = true;
    termux-open-url.enable = true;
    termux-setup-storage.enable = true;
  };
  system.stateVersion = "24.05";
}
