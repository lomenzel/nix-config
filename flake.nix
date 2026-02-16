{
  description = "flake for everything";

  inputs = {
    nvf.url = "github:notashelf/nvf";
    #nvf.inputs.nixpkgs.follows = "nixpkgs-unstable";
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
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-sbc-fix.url = "github:lomenzel/nixpkgs/update-sbc-to-2.2";
    nixpkgs-spidermonkey-fix.url = "github:lomenzel/nixpkgs/spidermonkey-fix-armv7l";
    nixpkgs-passes-fix.url = "github:lomenzel/nixpkgs/passes-fix-cross";
    nixpkgs-libglycin-fix-cross.url = "github:lomenzel/nixpkgs/libglycin-fix-cross";

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
    nixtheplanet.url = "github:matthewcroughan/nixtheplanet";
  };

  outputs =
    {
      self,
      nixpkgs,
      wsh,
      stylix,
      stylix-unstable,
      home-manager-unstable,
      home-manager,
      nix-luanti,
      nixtheplanet,
      ...
    }@inputs:

    let
      supportedSystems =
        [
          "x86_64-linux"
          "aarch64-linux"
          "armv7l-linux"
        ]
        |> builtins.map (system: {
          name = system;
          value = null;
        })
        |> builtins.listToAttrs;

      mkConfig =
        {
          hostPlatform ? "x86_64-linux",
          deviceModule,
          unstable ? true,
          secrets ? true,
        }:
        buildPlatform:
        let
          finalBuildPlatform = if buildPlatform != null then buildPlatform else hostPlatform;
        in
        inputs.${if unstable then "nixpkgs-unstable" else "nixpkgs"}.lib.nixosSystem rec {
          system = hostPlatform;
          specialArgs = {
            inherit inputs;
            pkgs-unstable = import inputs.nixpkgs-unstable {
              system = hostPlatform;
              overlays = defaultOverlays;
            };
            pkgs-self = self.packages.${hostPlatform};
            helper-functions = import ./helper-functions.nix;
          };
          modules = [
            deviceModule
            (
              { ... }:
              {
                nixpkgs.buildPlatform = buildPlatform;
                nixpkgs.hostPlatform = hostPlatform;
              }
            )
            inputs.nixtheplanet.nixosModules.macos-ventura
            (if unstable then stylix-unstable else stylix).nixosModules.stylix
            wsh.nixosModules.${hostPlatform}.default
            nix-luanti.nixosModules.default
            (if unstable then home-manager-unstable else home-manager).nixosModules.default
          ]
          ++ (if secrets then [ ./secrets ] else [ ])
          ++ builtins.attrValues inputs.self.nixosModules;
        };

      laptop = mkConfig { deviceModule = ./devices/laptop/configuration.nix; };
      tablet = mkConfig { deviceModule = ./devices/tablet/configuration.nix; };
      desktop = mkConfig { deviceModule = ./devices/desktop/configuration.nix; };
      pi = mkConfig {
        deviceModule = ./devices/pi/configuration.nix;
        hostPlatform = "aarch64-linux";
        secrets = false;
      };

      defaultOverlays = [
        inputs.nix-luanti.overlays.default
        (final: prev: {
          sbc = final.callPackage "${inputs.nixpkgs-sbc-fix}/pkgs/by-name/sb/sbc/package.nix" { };
          spidermonkey_140 =
            final.callPackage
              "${inputs.nixpkgs-spidermonkey-fix}/pkgs/development/interpreters/spidermonkey/140.nix"
              { };
          #fractal = final.callPackage "${inputs.nixpkgs-fractal-fix}/pkgs/by-name/fr/fractal/package.nix" { };
          passes = final.callPackage "${inputs.nixpkgs-passes-fix}/pkgs/by-name/pa/passes/package.nix" { };
          libglycin = final.callPackage "${inputs.nixpkgs-libglycin-fix-cross}/pkgs/by-name/li/libglycin/package.nix" {};
        })
      ];

      mini =
        buildPlatform:
        inputs.home-manager-unstable.lib.homeManagerConfiguration rec {
          pkgs =
            (import inputs.nixpkgs-unstable {
              system = buildPlatform;
              overlays = defaultOverlays;
            }).pkgsCross.armv7l-hf-multiplatform;
          extraSpecialArgs = {
            inherit inputs pkgs;
            pkgs-native = import inputs.nixpkgs-unstable {
              system = "armv7l-linux";
              overlays = defaultOverlays;
            };
            vim-config = import ./packages/vim.nix {inherit inputs; system = buildPlatform; cross = "armv7l-hf-multiplatform";};
          };
          modules = [
            ./devices/mini/home.nix
          ];
        };

    in

    {
      packages = builtins.mapAttrs (
        system: _:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          vim = import ./packages/vim.nix { inherit inputs system; };
          dns-update = pkgs.callPackage ./packages/dns-update { };
          pi = (pi system).config.system.build.sdImage;
        }
      ) supportedSystems;

      homeConfigurations.leonard = mini "x86_64-linux";

      nixosConfigurations = {
        laptop = laptop "x86_64-linux";
        tablet = tablet "x86_64-linux";
        desktop = desktop "x86_64-linux";
        pi = pi "aarch64-linux";
      };
      nixosModules = {
        inwx-dns-update = import ./modules/server/dyndns.nix;
      };

      checks = builtins.mapAttrs (
        system: _:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        (self.packages.${system})
        // {
          laptop = (laptop system).config.system.build.toplevel;
          tablet = (tablet system).config.system.build.toplevel;
          desktop = (desktop system).config.system.build.toplevel;
          mini = (mini system).activationPackage;
        }
      ) supportedSystems;
    };

}
