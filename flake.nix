# /etc/nixos/flake.nix
{
  description = "flake for laptop";

  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-unstable"; };
 

    wsh = {
      url = "github:lomenzel/web-command";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uex = {
      type = "gitlab";
      owner = "ux-cookie-banner";
      repo = "uex-cookie-banner-website";
      host = "git.mylab.th-luebeck.de";
      ref = "main";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };


  outputs = { self, nixpkgs,uex, nixos-cosmic, wsh, home-manager, ... }@inputs: {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          inputs.stylix.nixosModules.stylix

          
          wsh.nixosModules."x86_64-linux".default
          ./devices/laptop/configuration.nix
          inputs.home-manager.nixosModules.default
        ];

      };
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          secrets = import /home/leonard/.config/secrets/secrets.nix;
        };
        modules = [
         

          wsh.nixosModules."x86_64-linux".default
          ./devices/desktop/configuration.nix
          ./devices/desktop.nix
          inputs.stylix.nixosModules.stylix
          inputs.home-manager.nixosModules.default

        ];
      };
      pi = nixpkgs.lib.nixosSystem {
        
      };
      pp = nixpkgs.lib.nixosSystem {
        
      };
      fajita = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          inherit inputs;
          mobileNixos = inputs.mobile-nixos;
        };
        modules = [
          ({ config, pkgs, ... }: {
            imports = [
              (import "${inputs.mobile-nixos}/lib/configuration.nix" { device = "oneplus-fajita"; })
              "./devices/fajita/configuration.nix"
            ];
          })
        ];
      };
    };
  };
}
