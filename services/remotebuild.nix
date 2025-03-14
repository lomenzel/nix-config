{...}: {
  users.users.remotebuild = {
    isNormalUser = true;
    createHome = false;
    group = "remotebuild";
    openssh.authorizedKeys.keyFiles = [
      ./remotebuild.pub
      ./remotebuild-minive.pub
    ];
  };
  users.groups.remotebuild = {};
  nix.settings = {
    trusted-users = [ "remotebuild" ];
    max-jobs = 20;
    cores = 0;
    # substituters = [ "https://cache.menzel.lol" ];
    # trusted-public-keys = ["cache.menzel.lol:9HvL7GP4GKds1IiTJxRIRi63lOXixzcikeP9beSDrNk="];
  };
  boot.binfmt.emulatedSystems = [ "armv7l-linux" ];
}