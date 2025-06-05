# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  secrets,
  helper-functions,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../home/shell.nix
  ];

  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs secrets helper-functions;
    };
    users = {
      "leonard" = import ../../home-manager/pi-home.nix;
    };
    backupFileExtension = "homemanager-backup";
  };

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "pi";

  networking.networkmanager.enable = true;

  time.timeZone = "UTC";

  users.users.leonard = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  services.tor = {
    enable = true;
    client.enable = true;
    settings = {
      #seems to be by default
      #SOCKSPort = [ { port = 9050; } ];
      DNSPort = 9053;
      SOCKSPolicy = "accept 127.0.0.1:*";
      ClientUseIPv6 = false;
      EnforceDistinctSubnets = true;
    };
  };

  networking.nameservers = [ "127.0.0.1" ];
  services.resolved = {
    enable = true;
    extraConfig = "DNS=127.0.0.1:9053";
    fallbackDns = [ ];
  };

  services.transmission = {
    enable = true;
    settings = {
      download-dir = "/var/lib/transmission/Downloads";
      incomplete-dir-enabled = false;
      rpc-bind-address = "127.0.0.1";
      rpc-whitelist = "127.0.0.1";
      proxy = "socks5://127.0.0.1:9050";
      peer-port-random-on-start = false;
      port-forwarding-enabled = false;
      ratio-limit = 0;
      speed-limit-up = 1;
    };
  };
  systemd.services.transmission.serviceConfig = {
    PrivateNetwork = false;
    IPAddressDeny = "any";
    IPAddressAllow = "127.0.0.1";
    RestrictAddressFamilies = [ "AF_INET" ];
    NoNewPrivileges = true;
    PrivateTmp = true;
    ProtectSystem = "strict";
  };

  systemd.services.generate-selfsigned-cert = {
    description = "Generate self-signed TLS certificate for NGINX";
    wantedBy = [ "nginx.service" ];
    before = [ "nginx.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/mkdir -p /etc/ssl/certs /etc/ssl/private && ${pkgs.openssl}/bin/openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/selfsigned.key -out /etc/ssl/certs/selfsigned.crt  -subj \"/CN=192.168.178.21\" && ${pkgs.coreutils}/bin/chown nginx:nginx /etc/ssl/private/selfsigned.key /etc/ssl/certs/selfsigned.crt &&  ${pkgs.coreutils}/bin/chmod 600 /etc/ssl/private/selfsigned.key &&      ${pkgs.coreutils}/bin/chmod 644 /etc/ssl/certs/selfsigned.crt '";
      RemainAfterExit = true;
    };
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."192.168.178.21" = {
    sslCertificate = "/etc/ssl/certs/selfsigned.crt";
    sslCertificateKey = "/etc/ssl/private/selfsigned.key";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:9091";
      proxyWebsockets = true;

    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
      22
    ];
    allowedUDPPorts = [ ];
  };

  services.openssh.enable = true;

  system.stateVersion = "24.11";

}
