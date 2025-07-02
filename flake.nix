{
  description = "flake for everything";

  inputs = {
    nvf.url = "github:notashelf/nvf";
    # Stable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    speiseplan.url = "github:lomenzel/speiseplan-cli";

    # Unstable
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    stylix-unstable = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Master
    nixified-ai.url = "github:nixified-ai/flake";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-on-droid.url = "github:nix-community/nix-on-droid/master";
    shabitica.url = "github:lomenzel/shabitica";
    locationshare.url = "github:Importantus/location-share-backend";
    nix-luanti = {
      type = "gitlab";
      owner = "leonard";
      repo = "nix-luanti";
      host = "git.menzel.lol";
      ref = "main";
    };
    immich-uploader.url = "github:luigi311/immich_upload_daemon";
    wsh.url = "github:lomenzel/web-command";

    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";
  };

  outputs = {
    self,
    nixpkgs,
    #uex,
    wsh,
    home-manager,
    ...
  } @ inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} (
      {
        config,
        withSystem,
        moduleWithSystem,
        ...
      }: {
        imports = [
          inputs.devshell.flakeModule
        ];

        systems = builtins.attrNames nixpkgs.legacyPackages;

        perSystem = {
          config,
          pkgs,
          system,
          self',
          ...
        }: {
          packages = {
            vim = import ./packages/vim.nix {inherit inputs system;};
          };
          devshells = {
            default = {
              name = "leonard";
              env = [
                {
                  name = "TEST_VARIABLE";
                  value = "works";
                }
              ];
              commands = [
                {
                  command = "cowsay hello | lolcat";
                  name = "hello";
                }
              ];
              packages = with pkgs; [
                lolcat
                cowsay
                zsh
                self'.packages.vim
              ];
            };
          };
        };

        flake = {
          nixosConfigurations = {
            laptop = inputs.nixpkgs-unstable.lib.nixosSystem rec {
              system = "x86_64-linux";
              specialArgs = {
                inherit inputs;
                nixpkgs-unstable = import inputs.nixpkgs-unstable {inherit system;};
                pkgs-self = self.packages.${system};
                secrets = import /home/leonard/.config/secrets/secrets.nix;
                helper-functions = import ./helper-functions.nix;
                nix-luanti = inputs.nix-luanti.packages."x86_64-linux";
                pkgs-stable = import inputs.nixpkgs {system = "x86_64-linux";};
              };
              modules = with inputs; [
                stylix-unstable.nixosModules.stylix
                nixos-hardware.nixosModules.tuxedo-pulse-15-gen2
                wsh.nixosModules."x86_64-linux".default
                nix-luanti.nixosModules.default
                locationshare.nixosModules.default
                ./devices/laptop/configuration.nix
                home-manager-unstable.nixosModules.default
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

            desktop = let
              system = "x86_64-linux";
            in (inputs.nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = {
                inherit inputs;
                uex = inputs.uex;
                pkgs-self = self.packages.${system};
                nix-ai-stuff = inputs.nix-ai-stuff.packages.${system};
                secrets = import /home/leonard/.config/secrets/secrets.nix;
                helper-functions = import ./helper-functions.nix;
                nix-luanti = inputs.nix-luanti.packages."x86_64-linux";
                nixpkgs-unstable = import inputs.nixpkgs-unstable {system = "x86_64-linux";};
              };
              modules = with inputs; [
                wsh.nixosModules."x86_64-linux".default
                ./devices/desktop/configuration.nix
                ./devices/desktop.nix
                stylix.nixosModules.stylix
                home-manager.nixosModules.default
                locationshare.nixosModules.default
                nix-luanti.nixosModules.default
                inputs.nixified-ai.nixosModules.comfyui
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

            pp =
              nixpkgs.lib.nixosSystem {
              };
            fajita = nixpkgs.lib.nixosSystem {
              system = "aarch64-linux";
              specialArgs = {
                inherit inputs;
                mobileNixos = inputs.mobile-nixos;
              };
              modules = [
                (
                  {
                    config,
                    pkgs,
                    ...
                  }: {
                    imports = [
                      (import "${inputs.mobile-nixos}/lib/configuration.nix" {device = "oneplus-fajita";})
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
              overlays = [inputs.nix-on-droid.overlays.default];
            };
            modules = [./devices/pixel/nix-on-droid.nix];
            home-manager-path = home-manager.outPath;
          };
          homeConfigurations."droid" = home-manager.lib.homeManagerConfiguration {
            pkgs = import inputs.nixpkgs-unstable {system = "aarch64-linux";};
            modules = [
              ./experiments/pixel-home.nix
              inputs.nix-luanti.homeManagerModules.default
            ];
          };
          homeConfigurations."leonard" = home-manager.lib.homeManagerConfiguration {
            pkgs = import inputs.nixpkgs-unstable {
              system = "aarch64-linux";
            };
            modules = [
              (
                {pkgs, ...}: {
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

                  services.immich-upload = let
                    secrets = import /home/leonard/.config/secrets/secrets.nix;
                  in {
                    enable = true;
                    baseUrl = "https://photos.menzel.lol/api";
                    apiKey = secrets.immich.apiKey;
                    mediaPaths = ["~/Pictures/Camera"];
                  };
                  services.kdeconnect.enable = true;
                  programs.home-manager.enable = true;
                }
              )
            ];
          };
        };
      }
    );
}
