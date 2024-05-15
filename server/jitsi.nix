{ config, pkgs, ... }: {
  services.jitsi-meet = {
    enable = true;
    hostName = "meet.menzel.lol";
  };
}
