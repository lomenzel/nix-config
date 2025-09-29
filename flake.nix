{
  description = "flake for everything";

  inputs = {
    nvf.url = "github:notashelf/nvf";
    sops-nix.url = "github:Mic92/sops-nix";

    impermanence.url = "github:nix-community/impermanence";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    speiseplan.url = "github:draculente/speiseplan-cli";

    # Unstable
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    stylix-unstable = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Master
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-luanti = {
      type = "gitlab";
      owner = "leonard";
      repo = "nix-luanti";
      host = "git.menzel.lol";
      ref = "main";
    };
    immich-uploader.url = "github:lomenzel/immich_upload_daemon";
    wsh.url = "github:lomenzel/web-command";
  };

  outputs =
    {
      self,
      nixpkgs,
      wsh,
      home-manager,
      ...
    }@inputs:
    {

      packages = builtins.mapAttrs (
        system: _:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          vim = import ./packages/vim.nix { inherit inputs system; };
          dns-update = pkgs.callPackage ./packages/dns-update { };
        }
      ) nixpkgs.legacyPackages;

      nixosConfigurations = {
        laptop = inputs.nixpkgs-unstable.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit system;
              overlays = [
                inputs.nix-luanti.overlays.default
              ];
            };
            pkgs-self = self.packages.${system};
            helper-functions = import ./helper-functions.nix;
          };
          modules =
            with inputs;
            [
              stylix-unstable.nixosModules.stylix
              #nixos-hardware.nixosModules.tuxedo-pulse-15-gen2
              wsh.nixosModules."x86_64-linux".default
              nix-luanti.nixosModules.default
              ./secrets
              ./devices/laptop/configuration.nix
              #inputs.impermanence.nixosModules.impermanence
              home-manager-unstable.nixosModules.default
            ]
            ++ builtins.attrValues inputs.self.nixosModules;
        };
        desktop =
          let
            system = "x86_64-linux";
          in
          (inputs.nixpkgs-unstable.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit inputs;
              pkgs-self = self.packages.${system};
              legacy_secrets = import /home/leonard/.config/secrets/secrets.nix;
              helper-functions = import ./helper-functions.nix;
              nix-luanti = inputs.nix-luanti.packages."x86_64-linux";
              pkgs-unstable = import inputs.nixpkgs-unstable {
                system = "x86_64-linux";
                overlays = [ inputs.nix-luanti.overlays.default ];
              };
            };
            modules =
              with inputs;
              [
                wsh.nixosModules.${system}.default
                ./devices/desktop/configuration.nix
                ./secrets
                stylix-unstable.nixosModules.stylix
                home-manager-unstable.nixosModules.default
                nix-luanti.nixosModules.default
              ]
              ++ builtins.attrValues inputs.self.nixosModules;
          });
      };
      nixosModules = {
        inwx-dns-update = import ./modules/server/dyndns.nix;
      };
    };

}
