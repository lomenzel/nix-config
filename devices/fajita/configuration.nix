{
  config,
  pkgs,
  mobileNixos,
  ...
}:

{
  imports = [ ];

  # Basic system settings
  system.stateVersion = "23.05"; # Adjust to your nixpkgs version

  # Example of additional configuration
  networking.hostName = "fajita";

  users.users.root = {
    password = "root";
  };

  services.openssh.enable = true;

  # Mobile NixOS settings
  mobile.boot.stage-1.splash.enable = true;
}
