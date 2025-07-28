{ config, ... }:
{
  users.users.remotebuild = {
    isNormalUser = true;
    createHome = false;
    group = "remotebuild";
    openssh.authorizedKeys.keyFiles = [
      ./remotebuild-minive.pub
    ]
    ++ (if config.networking.hostName != "laptop" then [ ./remotebuild-laptop.pub ] else [ ]);
  };
  users.groups.remotebuild = { };
  nix.settings = {
    trusted-users = [ "remotebuild" ];
    max-jobs = "auto";
    #cores = ;
    # substituters = [ "https://cache.menzel.lol" ];
    # trusted-public-keys = ["cache.menzel.lol:9HvL7GP4GKds1IiTJxRIRi63lOXixzcikeP9beSDrNk="];
  };
  #boot.binfmt.emulatedSystems = [ "armv7l-linux" ];
}
