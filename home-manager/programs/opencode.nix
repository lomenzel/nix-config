{
  pkgs,
  inputs,
  ...
}: {
  programs.opencode = {
    enable = true;
    #package = inputs.nixpkgs-ollama.legacyPackages.${pkgs.hostPlatform.system}.opencode;
    context = ''
      Most of my projects are nix based. a few of them require my custom nix fork.
      usually they load it with direnv but sometimes it does not work.
      if you encounter errors like builtins.reify missing or something, thats exactly that.
      then try to run nix from github:lomenzel/nix with experimental feature ast-introspection enabled.

      if tools are not installed you allways can use nix run nixpkgs#tool -- args
      do **never** ls or grep the nix store to find derivations.

      focus on small tasks one by one. if not necessary do not try to solve multiple problems at once, instead make a todo for side quests and solve the issue first
      or the side quest first if required.
    '';
    extraPackages = [
      pkgs.nixd
      pkgs.nixfmt
    ];
    settings = {
      lsp = true;
      formatter = true;
      keybinds = {
        variant_list = "ctrl+v";
        variant_cycle = "ctrl+t";
      };
      provider.local = {
        options.baseURL = "http://10.44.1.2:11434/v1";
        options.timeout = 9000000;
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama";
        models = {
          "flash-next3.8q4" = {
            id = "qwen3.8-flash-next:125b-a6b-q4_K_M";
            name = "Qwen 3.8 Flash Next";
            cost = {
              input = 0.15;
              output = 0.25;
              cache_read = 0.01;
            };
            limit = {
              context = 131072;
              output = 32768;
            };
            variants = {
              low = {
                reasoningEffort = "low";
              };
              medium = {
                reasoningEffort = "medium";
              };
              xhigh = {
                reasoningEffort = "xhigh";
              };
            };
            reasoning = true;
          };
        };
      };
      small_model = "local/flash-next3.8q4";
      model = "local/flash-next3.8q4";
      disabled_providers = ["opencode"];
      agent = {
        title = {
          model = "local/flash-next3.8q4";
          variant = "low";
        };
        compaction = {
          model = "local/flash-next3.8q4";
          variant = "low";
        };
      };
    };
  };
}
