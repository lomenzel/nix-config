{ config, pkgs, ... }:
{
  imports = [
    ../home/home.nix
    #../home/vm.nix

    ../services/wsh.nix
    #../home/ipfs.nix 

    #../server/mysql.nix
    #../../kde2nix/nixos.nix
  ];

  /*
    nix.buildMachines = [{
      hostName = "ssh.menzel.lol";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      maxJobs = 32;
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
      sshUser = "leonard";
    }];
  */

  systemd.services.NetworkManager-wait-online.enable = false;

  nix.distributedBuilds = true;

  #hardware.tuxedo-rs.enable = true;
  #hardware.tuxedo-rs.tailor-gui.enable = true;

  nixpkgs.config.nativeOptimization = "native";
  virtualisation.docker.enable = true;
  #boot.kernelPackages = pkgs.linuxPackages_testing;

  services.openssh.settings.PermitRootLogin = "yes";
}
