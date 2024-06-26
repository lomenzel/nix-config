# /etc/nixos/flake.nix
{
  description = "flake for laptop";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

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
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  };

  outputs =
    {
      self,
      nixpkgs,
      uex,
      wsh,
      home-manager,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = with inputs; [
            stylix.nixosModules.stylix
            nixos-hardware.nixosModules.tuxedo-pulse-15-gen2
            wsh.nixosModules."x86_64-linux".default
            ./devices/laptop/configuration.nix
            home-manager.nixosModules.default
          ];

        };
	
	tablet = nixpkgs.lib.nixosSystem rec {
	  system = "x86_64-linux";
	  specialArgs =  {
	    inherit inputs;
	  };
 	  modules = [
		inputs.stylix.nixosModules.stylix
		wsh.nixosModules.${system}.default
		inputs.home-manager.nixosModules.default
		./devices/tablet/configuration.nix	
	  ];	
	};
	
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            secrets = import /home/leonard/.config/secrets/secrets.nix;
          };
          modules = with inputs; [
            wsh.nixosModules."x86_64-linux".default
            ./devices/desktop/configuration.nix
            ./devices/desktop.nix
            stylix.nixosModules.stylix
            home-manager.nixosModules.default

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
            (
              { config, pkgs, ... }:
              {
                imports = [
                  (import "${inputs.mobile-nixos}/lib/configuration.nix" { device = "oneplus-fajita"; })
                  "./devices/fajita/configuration.nix"
                ];
              }
            )
          ];
        };
      };
    };
}
