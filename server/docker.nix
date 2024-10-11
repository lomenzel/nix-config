{ pkgs, config, ...}: {
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      data-root = "/mnt/snd/Docker";
    };
  };
}