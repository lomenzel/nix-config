{
  config,
  pkgs-master,
  ...
}: {
  services.kubo = {
    package = pkgs-master.kubo;
    enable = true;
    localDiscovery = true;
    autoMount = true;
    enableGC = true;
    emptyRepo = false;
    settings.Addresses.API = "/ip4/127.0.0.1/tcp/5001";
    settings.Addresses.Gateway = "/ip4/127.0.0.1/tcp/8081";
  };
  users.users.leonard.extraGroups = [
    config.services.kubo.group
  ];
}