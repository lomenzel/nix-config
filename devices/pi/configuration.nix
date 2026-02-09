{ inputs, ... }:
{
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];
  nixpkgs.hostPlatform = "aarch64-linux";
  nixpkgs.buildPlatform = "x86_64-linux";

  users.users.remotebuild = {
    isNormalUser = true;
    createHome = false;
    group = "remotebuild";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGZ0h0NIhk9RORbSzqSvZbaWdP8GF4vLKJXq0vRKrfKV root@laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAKAKTZQ83XVl47MNeDBuSpDBacGO2iZk3BgicEQ0d7t root@mini"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJwiGVjy2K6pIUfQN2kYOy8D13DviLOYJ+/8R4kEtLxE leonard@desktop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF12/h6efxRizHua9BbyA7e9wmLPc+S8Cjge0pQlOxGw leonard@laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJOp8OfZYX8oARzccUZlc/9+5RHFypZ2KksuWCs0uQnm root@server"

    ];
  };
  users.groups.remotebuild = { };
  nix.settings = {
    trusted-users = [ "remotebuild" ];
    max-jobs = 1;
    extra-platforms = [ "armv7l-linux" ];
    system-features = ["benchmark" "big-parallel" "gccarch-armv8-a" "kvm" "nixos-test" "gccarch-armv7-a"];
  };
  zramSwap.enable = true;
  system.stateVersion = "26.05";
  networking.firewall.allowedTCPPorts = [ 22 ];
  services.openssh.enable = true;
}
