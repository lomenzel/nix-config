{ config, pkgs, ...}: {

    programs.vscode = {
        enable = true;
        userSettings = {
            "files.autoSave" = "afterDelay";
            "git.enableSmartCommit"= true;
        };
    };
    
}