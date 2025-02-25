{
  config,
  pkgs,
  secrets,
  inputs,
  pkgs-unstable,
  ...
}:
let
  #ollama-path = "/mnt/snd/ai/ollama";

in
{


  nixpkgs.config.allowUnfree = true;
  services = {
    ollama = {
      enable = true;
      port = 3500;
      host = "0.0.0.0";
      #home = ollama-path;
      #models = "${ollama-path}/models";
      loadModels = [
        "llama3.2:1b"
        "llama3.2:3b"
        "llama3.1:8b"
        "llama3.2-vision:11b"
        "llama3.3"
        "deepseek-r1:14b"
      ];
      acceleration = "cuda";
      package = pkgs-unstable.ollama;
    };
    nextjs-ollama-llm-ui = {
      enable = true;
      port = 3501;
      hostname = "0.0.0.0";
      package = pkgs-unstable.nextjs-ollama-llm-ui;
      ollamaUrl = "https://chat.ai.menzel.lol";
    };

/*
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
          proxy_read_timeout 3000s;
          proxy_send_timeout 3000s;
          proxy_connect_timeout 3000s;
        '';
      };
    };
    nginx.virtualHosts."ollama.menzel.lol" = {
      forceSSL = true;
      useACMEHost = "wildcard";
      basicAuth = secrets.basicAuth;
      locations."/" = {
        proxyPass = "http://localhost:3500";
        extraConfig = ''
          proxy_read_timeout 3000s;
          proxy_send_timeout 3000s;
          proxy_connect_timeout 3000s;
        '';
      };
    };
*/
  };


  systemd.services.ollama.serviceConfig = {
    TimeoutStartSec = "0";
  };
}
