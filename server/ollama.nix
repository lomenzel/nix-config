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
      package = pkgs-unstable.ollama-cuda.overrideAttrs {
        src = pkgs-unstable.fetchFromGitHub {
          owner = "ollama";
          repo = "ollama";
          hash = "sha256-joIA/rH8j+SJH5EVMr6iqKLve6bkntPQM43KCN9JTZ8=";
          tag = "v0.11.4";
        };
        version = "0.11.4";
      };
    };
  };

  systemd.services.ollama.serviceConfig = {
    TimeoutStartSec = "0";
  };
}
