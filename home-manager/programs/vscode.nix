{ config, lib, pkgs, helper-functions, secrets, ... }: with (helper-functions {inherit lib;});
{

  home.packages = [ pkgs.nixfmt-rfc-style ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium-fhs;
    haskell = {
      enable = true;
      hie.enable = true;
    };
    enableUpdateCheck = false;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      jnoortheen.nix-ide
      continue.continue
      ms-vscode-remote.remote-containers
      haskell.haskell
      justusadam.language-haskell
      ms-vscode.live-server
      ms-python.python
      ms-python.debugpy
      ms-pyright.pyright
      ms-python.vscode-pylance
      ms-python.black-formatter
      tomoki1207.pdf
      redhat.vscode-yaml
    ];

    userSettings = {
      "files.autoSave" = "afterDelay";
      "git.enableSmartCommit" = true;
      "git.confirmSync" = false;
      "haskell.hlint.executablePath" = "${pkgs.hlint}/bin/hlint";
      "explorer.confirmDragAndDrop" = false;
      "git.autofetch" = true;
    };
  };

  home.file =
    let
      desktop = {
        title = "Desktop";
        provider = "ollama";
        model = "llama3:8b";
        apiBase = "https://chat.ai.menzel.lol/";
        requestOptions = {
          headers = {
            Authorization = "Basic ${toBase64 "alpaka:${secrets.basicAuth.alpaka}"}";
          };
        };
      };
    in
    {
      ".continue/config.json".text = builtins.toJSON {
        models = [ desktop ];
        tabAutocompleteModel = desktop;
      };
    };

}
