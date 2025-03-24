{pkgs,...}:{
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;

 nix.settings = {
    substituters = [
      "https://cache.menzel.lol"
    ];
    trusted-public-keys = ["cache.menzel.lol:9HvL7GP4GKds1IiTJxRIRi63lOXixzcikeP9beSDrNk="];
  };

  nix.buildMachines = [
    {
      hostName = "menzel.lol";
      sshUser = "remotebuild";
      sshKey = "/root/.ssh/remotebuild";
      system = pkgs.stdenv.hostPlatform.system;
      maxJobs = 31;
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "big-parallel" "kvm" ];
    }
  ];
}