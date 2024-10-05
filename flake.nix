# /etc/nixos/flake.nix
{
  description = "flake for laptop";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/master";
    };

    wsh = {
      url = "github:lomenzel/web-command";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # uex = {
    #   type = "gitlab";
    #   owner = "ux-cookie-banner";
    #   repo = "uex-cookie-banner-website";
    #   host = "git.mylab.th-luebeck.de";
    #   ref = "main";
    # };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nix-ai-stuff = {
    #   url = "github:BatteredBunny/nix-ai-stuff";
    #   #inputs.nixpkgs.follows = "nixpkgs";
    # };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
    simple-nixos-mailserver.inputs.nixpkgs.follows = "nixpkgs";
    nix-on-droid.url = "github:nix-community/nix-on-droid/master";
    shabitica.url = "github:lomenzel/shabitica";

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
        laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            secrets = import /home/leonard/.config/secrets/secrets.nix;
            helper-functions = import ./helper-functions.nix;

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
          (nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit inputs;
              uex = inputs.uex;
              nix-ai-stuff = inputs.nix-ai-stuff.packages.${system};
              secrets = import /home/leonard/.config/secrets/secrets.nix;
              helper-functions = import ./helper-functions.nix;

            };
            modules = with inputs; [
              wsh.nixosModules."x86_64-linux".default
              ./devices/desktop/configuration.nix
              ./devices/desktop.nix
              stylix.nixosModules.stylix
              home-manager.nixosModules.default
              inputs.simple-nixos-mailserver.nixosModule

            ];
          });
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
      nixOnDroidConfigurations.default = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-linux";
          overlays = [ inputs.nix-on-droid.overlays.default ];
        };
        modules = [ ./devices/pixel/nix-on-droid.nix ];
        home-manager-path = home-manager.outPath;
      };

      # not working and i dont want to deal with it anymore
      packages.epg =
        let
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          pname = "epg";
          version = "2023.12.1";
          src = pkgs.fetchFromGitHub {
            owner = "iptv-org";
            repo = pname;
            rev = version;
            hash = "sha256-4YS7ZscNPPMK0V2U1uDgBKfQa0qSpa3LG0yl1zYkjDA=";
          };
        in
        pkgs.stdenv.mkDerivation rec {

          inherit src version pname;
          buildInputs = [pkgs.nodejs];
          installPhase = ''
            mkdir -p $out/.npm
            cp -r $src/* $out/
            cp -r ${
              pkgs.fetchNpmDeps {
                inherit src;
                hash = "sha256-D3poXVVq7VfOF9GhDyC9k5MOhsBSVffCokA0HSC5WCU=";
              }
            }/_cacache $out/.npm/
            export npm_config_cache=$out/.npm/_cacache
            npm config get cache
            find $out/.npm/_cacache -name "*yocto-queue*"
            exit 1
            npm install --offline --no-audit --no-fund
            cp -r ./node_modules $out/
          '';
        };
    };
}
