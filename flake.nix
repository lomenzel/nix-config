# /etc/nixos/flake.nix
{
  description = "flake for laptop";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/commit/426c785e7de6619b774601f8cda4655d9fbc16e7";
    };

    wsh = {
      url = "github:lomenzel/web-command";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, wsh, home-manager }@inputs: {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [


          wsh.nixosModules."x86_64-linux".default
          ./devices/laptop/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
	
      };
      desktop = nixpkgs.lib.nixosSystem {
	system = "x86_64-linux";
       specialArgs = {inherit inputs;};
        modules = [

          wsh.nixosModules."x86_64-linux".default
		      /etc/nixos/configuration.nix
		      ./devices/desktop.nix
          inputs.home-manager.nixosModules.default

	];
      };
    };
  };
}