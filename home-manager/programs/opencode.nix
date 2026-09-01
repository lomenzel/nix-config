{...}: {
  programs.opencode = {
    enable = true;
    context = ''
      Most of my projects are nix based. a few of them require my custom nix fork. usually they load it with direnv but sometimes it does not work. if you encounter errors like builtins.reify missing or something, thats exactly that. then try to run nix from github:lomenzel/nix with experimental feature ast-introspection enabled.
    '';
    settings = {
      provider.ollama = {
        options.baseURL = "http://10.44.1.2:11434/v1";
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama";
        models = {
          "olmo-3.1:32b".name = "Olmo 3.1";
          "qwen3.8:27b".name = "Qwen 3.8";
        };
      };
      model = "ollama/qwen3.8:27b";
      disabled_providers = ["opencode"];
    };
  };
}
