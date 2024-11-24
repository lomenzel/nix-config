{ config, pkgs, ... }:
let
  kubeMasterIP = "192.168.178.61"; # Replace with your desktop's static IP
  kubeMasterHostname = "menzel.lol";
  kubeMasterAPIServerPort = 6443;
in
{
  # Resolve master hostname
  networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";

  # Install packages for Kubernetes
  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
  ];

  services.kubernetes = {
    roles = [
      "master"
      "node"
    ]; # Desktop will be both master and worker
    masterAddress = kubeMasterHostname;
    apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
    easyCerts = true; # Use simple certificates
    apiserver = {
      securePort = kubeMasterAPIServerPort;
      advertiseAddress = kubeMasterIP;
    };

    # Enable CoreDNS
    addons.dns.enable = true;

    # Disable swap for Kubernetes
    kubelet.extraOpts = "--fail-swap-on=false";
  };
}
