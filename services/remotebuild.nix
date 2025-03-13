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
  nix.settings.trusted-users = [ "remotebuild" ];
  boot.binfmt.emulatedSystems = [ "armv7l-linux" ];
}