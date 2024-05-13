# /etc/nixos/flake.nix
{
  description = "flake for laptop";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
  nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wsh = {
      url = "github:draculente/web-command";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-cosmic, wsh, home-manager }@inputs: {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        extraSpecialArgs = {inherit inputs;};
        modules = [
           {
            nix.settings = {
              substituters = [ "https://cosmic.cachix.org/" ];
              trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
            };
          }
          nixos-cosmic.nixosModules.default
          wsh.nixosModules."x86_64-linux".default
          ./devices/laptop/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
	
      };
      desktop = nixpkgs.lib.nixosSystem {
	system = "x86_64-linux";
       extraSpecialArgs = {inherit inputs;};
        modules = [
           {
            nix.settings = {
              substituters = [ "https://cosmic.cachix.org/" ];
              trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
            };
          }
          nixos-cosmic.nixosModules.default
          wsh.nixosModules."x86_64-linux".default
		      /etc/nixos/configuration.nix
		      ./devices/desktop.nix
          inputs.home-manager.nixosModules.default

	];
      };
    };
  };
}