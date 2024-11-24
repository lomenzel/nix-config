{ config, pkgs, ... }:
let
  kubeMasterIP = "192.168.178.61"; # Desktop's IP
  kubeMasterHostname = "menzel.lol";
  kubeMasterAPIServerPort = 6443;
in
{
  # Resolve master hostname
  networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";

  # Install Kubernetes packages
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes
  ];

  services.kubernetes = {
    roles = [ "node" ];
    masterAddress = kubeMasterHostname;
    apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
    easyCerts = true;

    # Kubelet options to prevent the node from scheduling workloads
    kubelet.extraOpts = "--register-with-taints=node-role.kubernetes.io/storage=true:NoSchedule";
  };
}
