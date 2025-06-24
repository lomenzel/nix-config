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

  home.packages = [ pkgs.nixfmt-rfc-style ];

  stylix.targets.vscode.profileNames = [ "default" ];

  programs.vscode = {
    enable = true;
    #package = pkgs.vscodium-fhs;
    haskell = {
      #enable = true;
      #hie.enable = true;
    };

    profiles.default.enableUpdateCheck = false;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      jnoortheen.nix-ide
      continue.continue
      ms-vscode-remote.remote-containers
      haskell.haskell
      justusadam.language-haskell
      ms-vscode.live-server
      tomoki1207.pdf
      redhat.vscode-yaml
    ];

    profiles.default.userSettings = {
      "files.autoSave" = "afterDelay";
      "git.enableSmartCommit" = true;
      "git.confirmSync" = false;
      "explorer.confirmDragAndDrop" = false;
      "git.autofetch" = true;
      "redhat.telemetry.enabled" = false;
    };

  };

  home.file =
    let
      desktop = model: {
        title = "${model}@desktop";
        provider = "ollama";
        model = model;
        apiBase = "https://chat.ai.menzel.lol/";
        requestOptions = {
          headers = {
            Authorization = "Basic ${toBase64 "menzel:${secrets.basicAuth.menzel}"}";
          };
        };
      };
    in
    {
      ".continue/config.json".text = builtins.toJSON {
        models = [
          (desktop "llama3.2:3b")
          (desktop "llama3.2:1b")
          (desktop "deepseek-r1:14b")
        ];
        tabAutocompleteModel = desktop "llama3.2:3b";
      };
    };

}
