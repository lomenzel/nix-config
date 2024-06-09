{ config, pkgs, ...}: {

    programs.vscode = {
        enable = true;
        userSettings = {
            "files.autoSave" = "afterDelay";
            "git.enableSmartCommit"= true;
            "git.confirmSync" =  false;
            "haskell.hlint.executablePath" = "${pkgs.hlint}/bin/hlint";
        };
    };
    
}