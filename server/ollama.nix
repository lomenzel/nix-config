{ config, pkgs, secrets, ... }: let
  ollama-path = "/mnt/snd/ai/ollama";

in {

  services = {
    ollama = {
      enable = true;
      port = 3500;
      host = "0.0.0.0";
      home = ollama-path;
      models = "${ollama-path}/models";
      writablePaths = [
        ollama-path
      ];
      acceleration = "cuda";
    };
    nextjs-ollama-llm-ui = {
      enable = true;
      port = 3501;
      ollamaUrl = "http://127.0.0.1:3500";
    };

    nginx.virtualHosts."chat.ai.menzel.lol" = {
      forceSSL = true;
      useACMEHost = "ai-wildcard";
      basicAuth = secrets.basicAuth;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3501";
      };
    };

  };
}