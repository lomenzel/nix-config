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
    #package = pkgs.vscodium-fhs;
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
      "C_Cpp.intelliSenseEngine" ="disabled";
    };

  };

}
