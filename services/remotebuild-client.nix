{ pkgs, ... }:
{
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;

  nix.settings = {
    substituters = [
      # "https://cache.menzel.lol"
    ];
    trusted-public-keys = [
      # "cache.menzel.lol:9HvL7GP4GKds1IiTJxRIRi63lOXixzcikeP9beSDrNk="
    ];
  };

  programs.ssh.extraConfig = ''
    host pi
      HostName menzel.lol
      Port 2222
      User remotebuild
      IdentityFile /root/.ssh/remotebuild
      IdentitiesOnly yes
  '';

  nix.buildMachines = [
    {
      hostName = "menzel.lol";
      sshUser = "remotebuild";
      sshKey = "/root/.ssh/remotebuild";
      system = "x86_64-linux";
      maxJobs = 8;
      speedFactor = 2;
      supportedFeatures = [
        "nixos-test"
        "big-parallel"
        "kvm"
      ];
    }
    {
      hostName = "pi";
      sshUser = "remotebuild";
      sshKey = "/root/.ssh/remotebuild";
      system = "aarch64-linux,armv7l-linux";
      maxJobs = 1;
      speedFactor = 1;
      supportedFeatures = [
        "nixos-test"
        "gccarch-armv7-a"
      ];
    }
  ];
}
