{ config, pkgs, ...}: {

    programs.vscode = {
        enable = true;
        userSettings = {
            "files.autoSave" = "afterDelay";
        };
    };
    
}