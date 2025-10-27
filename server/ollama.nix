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
      home = "/mnt/server/ollama";
      user = "ollama";
      enable = true;
      port = 3500;
      host = "0.0.0.0";
      loadModels = [
        "llama3.1:8b"
        "gpt-oss:20b"
        "gpt-oss:120b"
        "qwen3-coder:30b"
        "qwen3:14b"
        "deepcoder:14b"
        "llama4:16x17b"
        "deepseek-r1:14b"

      ];
      acceleration = "cuda";
      package = pkgs-unstable.ollama-cuda;
    };
  };

  systemd.services.ollama.serviceConfig = {
    TimeoutStartSec = "0";
  };
}
