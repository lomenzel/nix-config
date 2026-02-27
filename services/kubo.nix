{
  ...
}: {
  services.kubo = {
    enable = true;
    localDiscovery = true;
    autoMount = true;
    enableGC = true;
    emptyRepo = false;
  };
}