{
  config,
  pkgs,
  inputs,
  lib,
  secrets,
  helper-functions,
  nixpkgs-unstable,
  pkgs-stable,
  pkgs-self,
  ...
}:

{
  imports = [
    ./shell.nix
    ./desktop.nix
  ];

  home-manager = {
    extraSpecialArgs = {
      inherit
        inputs
        secrets
        helper-functions
        nixpkgs-unstable
        pkgs-stable
        pkgs-self
        ;
    };
    users = {
      "leonard" = import ../home-manager/home.nix;
    };
    backupFileExtension = "homemanager-backup";
  };

  services.xserver.enable = true;

  nix.settings.trusted-users = [
    "root"
    "leonard"
  ];

  nix.sshServe.write = true;
  nix.sshServe.enable = true;

  boot.plymouth = {
    enable = true;
  };

  /*
    boot.binfmt.emulatedSystems = [
      "aarch64-linux"
      "aarch64_be-linux"
      "alpha-linux"
      "armv6l-linux"
      "armv7l-linux"
      "i386-linux"
      "i486-linux"
      "i586-linux"
      "i686-linux"
      "i686-windows"
      "loongarch64-linux"
      "mips-linux"
      "mips64-linux"
      "mips64-linuxabin32"
      "mips64el-linux"
      "mips64el-linuxabin32"
      "mipsel-linux"
      "powerpc-linux"
      "powerpc64-linux"
      "powerpc64le-linux"
      "riscv32-linux"
      "riscv64-linux"
      "sparc-linux"
      "sparc64-linux"
      "wasm32-wasi"
      "wasm64-wasi"
      #"x86_64-linux"
      "x86_64-windows"
    ];
  */

  programs.adb.enable = true;
  programs.partition-manager.enable = true;

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  programs.ausweisapp.enable = true;
  programs.ausweisapp.openFirewall = true;

  services.openssh.enable = true;
  services.fwupd.enable = true;
  services.flatpak.enable = true;
  xdg.portal.enable = true;

  users.users.leonard = {
    isNormalUser = true;
    description = "Leonard Menzel";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "docker"
      "adbusers"
      "dialout"
      "plugdev"
    ];
    packages =
      with pkgs;
      with kdePackages;
      [

        exfat
        exfatprogs
        #parabolic
        glxinfo
        clinfo
        wayland-utils
        pciutils
        vulkan-tools
        #kmail
        kontact
        kmail-account-wizard
        akonadi-import-wizard
        #neochat
      ];
  };

}
