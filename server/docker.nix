{ pkgs, config, ...}: {
  virtualistion.docker = {
    enable = true;
    daemon.settings {
      data-root = "/mnt/snd/Docker";
    };
  };
}