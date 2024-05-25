{ config, pkgs, ... }: {




    users.users.leonard.packages = with pkgs; [ 
        (pkgs.callPackage ../../apps/spacemash.nix {inherit pkgs;})
    ]
}