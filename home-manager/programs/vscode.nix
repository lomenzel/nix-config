{
  config,
  lib,
  pkgs,
  helper-functions,
  secrets,
  ...
}:
with (helper-functions { inherit lib; });
{

  home.packages = [ pkgs.nixfmt ];

  stylix.targets.vscode.profileNames = [ "default" ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        find $out -name "copilot-runtime" -exec chmod +x {} +
      '';
    });
    haskell = {
      #enable = true;
      #hie.enable = true;
    };

    profiles.default.enableUpdateCheck = false;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      jnoortheen.nix-ide
      ms-vscode-remote.remote-containers
    ];

    profiles.default.userSettings = {
      "files.autoSave" = "afterDelay";
      "git.enableSmartCommit" = true;
      "git.confirmSync" = false;
      "explorer.confirmDragAndDrop" = false;
      "git.autofetch" = true;
      "redhat.telemetry.enabled" = false;
      "C_Cpp.intelliSenseEngine" = "disabled";
      "github.copilot.enable" = {
        "*" = false;
        "plaintext" = false;
        "markdown" = false;
        "scminput" = false;
      };
    };

  };

  home.file.chatLanguageModels = {
    enable = true;
    force = true;
    target = ".config/Code/User/chatLanguageModels.json";
    text = builtins.toJSON [
      {
        name = "Local Ollama";
        vendor = "customendpoint";
        apiType = "chat-completions";
        apiKey = "ollama";
        models = [
          {
            id = "qwen3.8-flash-next:125b-a6b-q4_K_M";
            name = "Qwen 3.8 Flash Next";
            url = "http://10.44.1.2:11434/v1/chat/completions";
            toolCalling = true;
            thinking = true;
            vision = true;
            maxInputTokens = (1024 * 256) - (1024 * 32);
            maxOutputTokens = 1024 * 32;
          }
        ];
      }
    ];
  };

}
