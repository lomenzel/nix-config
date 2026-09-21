{
  pkgs,
  inputs,
  ...
}: {
  programs.opencode = {
    enable = true;
    package = inputs.nixpkgs-ollama.legacyPackages.${pkgs.hostPlatform.system}.opencode;
    context = ''
      Most of my projects are nix based. a few of them require my custom nix fork. usually they load it with direnv but sometimes it does not work. if you encounter errors like builtins.reify missing or something, thats exactly that. then try to run nix from github:lomenzel/nix with experimental feature ast-introspection enabled.
    '';
    settings = {
      provider.ollama = {
        options.baseURL = "http://10.44.1.2:11434/v1";
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama";
        models = {
          "qwen3.8-flash-next:125b-a6b-q4_K_M" = {
            name = "Qwen 3.8 Flash Next";
            limit = {
              context = 65536;
              output = 8192;
            };
          };
          "olmo-3.1:32b" = {
            name = "Olmo 3.1";
            limit = {
              context = 65536;
              output = 8192;
            };
          };

          "qwen3.8:27b" = {
            name = "Qwen 3.8";
            limit = {
              context = 65536;
              output = 8192;
            };
            variants = {
              low = {reasoningEffort = "low";};
              medium = {reasoningEffort = "medium";};
              high = {reasoningEffort = "high";};
              xhigh = {reasoningEffort = "xhigh";};
            };
          };
        };
      };
      small_model = "ollama/qwen3.8:27b";
      model = "ollama/qwen3.8:27b";
      disabled_providers = ["opencode"];
      agent = {
        title.model = "ollama/qwen3.8:27b";
        compaction.model = "ollama/qwen3.8:27b";
      };
    };
  };
}
