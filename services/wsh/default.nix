{ ... }:
{
  services.wsh = {
    enable = true;
    host_mode = "local";
    configFile = ./config.toml;
  };
}
