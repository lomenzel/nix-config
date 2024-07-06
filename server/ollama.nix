{
  config,
  pkgs,
  secrets,
  ...
}:
let
  ollama-path = "/mnt/snd/ai/ollama";

in
{

  services = {
    ollama = {
      enable = true;
      port = 3500;
      host = "0.0.0.0";
      home = ollama-path;
      models = "${ollama-path}/models";
      loadModels = [
        "llama3:8b"
        "llama3:70b"
        "deepseek-coder-v2:16b"
        "codestral:22b"
        "starcoder:15b"
        "gemma2:9b"
        "gemma2:27b"
        "codegemma:2b"
        "codegemma:7b"
        "wizard-vicuna-uncensored:30b"
      ];
      writablePaths = [ ollama-path ];
      acceleration = "cuda";
    };
    nextjs-ollama-llm-ui = {
      enable = true;
      port = 3501;
      ollamaUrl = "https://chat.ai.menzel.lol";
    };

    nginx.virtualHosts."chat.ai.menzel.lol" = {
      forceSSL = true;
      useACMEHost = "ai-wildcard";
      basicAuth = secrets.basicAuth;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3501";
      };
      locations."/api" = {
        proxyPass = "http://localhost:3500";
        extraConfig = ''
          proxy_read_timeout 300s;
          proxy_send_timeout 300s;
          proxy_connect_timeout 300s;
        '';
      };
    };

  };

  systemd.services.ollama.serviceConfig = {
    TimeoutStartSec = "0";
  };
}
