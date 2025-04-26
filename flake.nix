# /etc/nixos/flake.nix
{
  description = "flake for laptop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    pkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    wsh.url = "github:lomenzel/web-command";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "pkgs-unstable";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "pkgs-unstable";
    };
    nix-ai-stuff.url = "github:BatteredBunny/nix-ai-stuff";
    inputs.nixified-ai.url = "github:matthewcroughan/nixified-ai";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-on-droid.url = "github:nix-community/nix-on-droid/master";
    #shabitica.url = "github:lomenzel/shabitica/ce63bafcde6d7fddc50430aa14e9c7f6839826df";
    shabitica.url = "path:/home/leonard/Projekte/shabitica";

    #locationshare.url = "path:/home/leonard/Projekte/location-share-backend";
    locationshare.url = "github:Importantus/location-share-backend";
    /*
      nix-luanti = {
        #url = "github:lomenzel/nix-luanti";
        url = "path:/home/leonard/Projekte/nix-minetest";
        #inputs.nixpkgs.follows = "nixpkgs";
        #inputs.flake-utils.follows = "flake-utils";
      };
    */
    nix-luanti = {
      type = "gitlab";
      owner = "leonard";
      repo = "nix-luanti";
      host = "git.menzel.lol";
      ref = "main";
    };
    immich-uploader.url = "github:luigi311/immich_upload_daemon";

  };

  outputs =
    {
      self,
      nixpkgs,
      #uex,
      wsh,
      home-manager,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        laptop = inputs.pkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            pkgs-unstable = import inputs.pkgs-unstable { system = "x86_64-linux"; };
            secrets = import /home/leonard/.config/secrets/secrets.nix;
            helper-functions = import ./helper-functions.nix;
            nix-luanti = inputs.nix-luanti.packages."x86_64-linux";
            pkgs-stable = import inputs.nixpkgs { system = "x86_64-linux"; };
          };
          modules = with inputs; [
            stylix.nixosModules.stylix
            nixos-hardware.nixosModules.tuxedo-pulse-15-gen2
            wsh.nixosModules."x86_64-linux".default
            nix-luanti.nixosModules.default
            locationshare.nixosModules.default
            ./devices/laptop/configuration.nix
            home-manager.nixosModules.default
          ];

        };

        tablet = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            secrets = import /home/leonard/.config/secrets/secrets.nix;
            helper-functions = import ./helper-functions.nix;
          };
          modules = [
            inputs.stylix.nixosModules.stylix
            wsh.nixosModules.${system}.default
            inputs.home-manager.nixosModules.default
            ./devices/tablet/configuration.nix
          ];
        };

        desktop =
          let
            system = "x86_64-linux";
          in
          (inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit inputs;
              uex = inputs.uex;
              nix-ai-stuff = inputs.nix-ai-stuff.packages.${system};
              secrets = import /home/leonard/.config/secrets/secrets.nix;
              helper-functions = import ./helper-functions.nix;
              nix-luanti = inputs.nix-luanti.packages."x86_64-linux";
              pkgs-unstable = import inputs.pkgs-unstable { system = "x86_64-linux"; };
            };
            modules = with inputs; [
              wsh.nixosModules."x86_64-linux".default
              ./devices/desktop/configuration.nix
              ./devices/desktop.nix
              stylix.nixosModules.stylix
              home-manager.nixosModules.default
              locationshare.nixosModules.default
              nix-luanti.nixosModules.default
              inputs.nixified-ai.nixosModules.comfyui;
            ];
          });
        pi = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit inputs;
            secrets = import /home/leonard/.config/secrets/secrets.nix;
            helper-functions = import ./helper-functions.nix;
          };
          modules = with inputs; [
            #stylix.nixosModules.stylix
            nixos-hardware.nixosModules.raspberry-pi-4
            ./devices/pi/configuration.nix
            home-manager.nixosModules.default
          ];

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
      nixOnDroidConfigurations.default = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-linux";
          overlays = [ inputs.nix-on-droid.overlays.default ];
        };
        modules = [ ./devices/pixel/nix-on-droid.nix ];
        home-manager-path = home-manager.outPath;
      };
      homeConfigurations."droid" = home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.pkgs-unstable { system = "aarch64-linux"; };
        modules = [
          ./experiments/pixel-home.nix
          inputs.nix-luanti.homeManagerModules.default
        ];
      };
      homeConfigurations."leonard" = home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.pkgs-unstable {
          system = "aarch64-linux";
        };
        modules = [
          (
            { pkgs, ... }:
            {
              imports = [
                inputs.immich-uploader.homeManagerModules.default
              ];
              home.username = "leonard";
              home.homeDirectory = "/home/leonard";
              home.stateVersion = "25.05";
              home.packages = with pkgs; [
                nix-output-monitor
                nh
                finamp
                git

              ];

              services.immich-upload =
                let

                  secrets = import /home/leonard/.config/secrets/secrets.nix;

                in
                {
                  enable = true;
                  baseUrl = "https://photos.menzel.lol/api";
                  apiKey = secrets.immich.apiKey;
                  mediaPaths = [ "~/Pictures/Camera" ];
                };
              services.kdeconnect.enable = true;
              programs.home-manager.enable = true;
            }
          )
        ];
      };
    };
}
