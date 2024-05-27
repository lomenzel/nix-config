{ config, pkgs, ... }: {
  imports = [
    ../home/home.nix
    ../home/vm.nix

    ../services/wsh.nix
    #../home/ipfs.nix 
    #../home/vm.nix 
    #../server/mysql.nix
    #../../kde2nix/nixos.nix
  ];

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

  systemd.services.NetworkManager-wait-online.enable = false;

  nix.distributedBuilds = true;

  hardware.tuxedo-rs.enable = true;
  hardware.tuxedo-rs.tailor-gui.enable = true;

  nixpkgs.config.nativeOptimization = "native";
  virtualisation.docker.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_testing;

  services.openssh.settings.PermitRootLogin = "yes";

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages

    ocl-icd
    stdenv.cc.cc
    intel-ocl
    p7zip
    alsa-lib
    fpm
    gcc
    libgcc
    nss.out
    nss
    dbus
    atkmm
    atkmm.out
    dbus.out
    dbus-glib
    dbus-glib.out
    nspr
    nspr.out
    glib
    electron
    mesa
    at-spi2-atk
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
    libxkbcommon
    expat
    glibc
    libdrm
    cups
    pango
    cairo
    gtk4
    gtk3
    glib.out
    libgccjit
    stdenv.cc.cc.lib
    libstdcxx5
  ];

}
