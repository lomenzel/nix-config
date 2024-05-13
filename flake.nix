# /etc/nixos/flake.nix
{
  description = "flake for laptop";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/98739384322150c85dd6979d7bf763f8916200c0";
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