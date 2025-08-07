{
  config,
  pkgs-unstable,
  inputs,
  ...
}:
{

  nixpkgs.config.allowUnfree = true;
  services = {
    ollama = {
      enable = true;
      port = 3500;
      host = "0.0.0.0";
      loadModels = [
        "llama3.1:8b"
      ];
      acceleration = "cuda";
      package = pkgs-unstable.ollama-cuda;
    };
  };

  systemd.services.ollama.serviceConfig = {
    TimeoutStartSec = "0";
  };
}
