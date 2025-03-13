{ config
, pkgs
, nix-luanti
, inputs
, secrets
, ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../laptop.nix
    ../../services/remotebuild-client.nix
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
    "jitsi-meet-1.0.8043"
  ];
  networking.firewall.enable = false;

  services.udev.extraRules = ''
    # STMicroelectronics STLink V2
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="0666", GROUP="plugdev"

    # STMicroelectronics STLink V2-1
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE="0666", GROUP="plugdev"

    # STMicroelectronics STLink V3
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374f", MODE="0666", GROUP="plugdev"

    SUBSYSTEM=="tty", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE="0666", GROUP="dialout", SYMLINK+="stm32_nucleo"
  '';

  # Optional: Paket, das ST-Link und OpenOCD enthält
  # services.udev.packages = [ pkgs.openocd pkgs.stlink ];

  services.location-share = {
    enable = true;
    port = 3457;
    googleApplicationCredentials = secrets.locationshare.credentials;
  };

  services.luanti = {
    enable = true;
    package = inputs.pkgs-unstable.legacyPackages."x86_64-linux".luanti-server;
    whitelist = [ "leonard" ];
    servers = with nix-luanti; {
      test = {
        game = games.mineclone2;
        port = 30000;
        mods = with mods; [
          logistica
          everness
        ];
        config = {
          # recommended everness config for VoxeLibre
          everness_coral_forest = true;
          everness_coral_forest_y_max = 194;
          everness_coral_forest_y_min = 6;
          everness_coral_forest_dunes = true;
          everness_coral_forest_dunes_y_max = 5;
          everness_coral_forest_dunes_y_min = 4;
          everness_coral_forest_ocean = true;
          everness_coral_forest_ocean_y_max = 3;
          everness_coral_forest_ocean_y_min = -10;
          everness_coral_forest_deep_ocean = true;
          everness_coral_forest_deep_ocean_y_max = -11;
          everness_coral_forest_deep_ocean_y_min = -62;
          everness_coral_forest_under = true;
          everness_coral_forest_under_y_max = -28939;
          everness_coral_forest_under_y_min = -29067;
          everness_frosted_icesheet = true;
          everness_frosted_icesheet_y_max = 194;
          everness_frosted_icesheet_y_min = -8;
          everness_frosted_icesheet_ocean = true;
          everness_frosted_icesheet_ocean_y_max = -9;
          everness_frosted_icesheet_ocean_y_min = -62;
          everness_frosted_icesheet_under = true;
          everness_frosted_icesheet_under_y_max = -28939;
          everness_frosted_icesheet_under_y_min = -29067;
          everness_cursed_lands = true;
          everness_cursed_lands_y_max = 194;
          everness_cursed_lands_y_min = 6;
          everness_cursed_lands_dunes = true;
          everness_cursed_lands_dunes_y_max = 5;
          everness_cursed_lands_dunes_y_min = 1;
          everness_cursed_lands_swamp = true;
          everness_cursed_lands_swamp_y_max = 0;
          everness_cursed_lands_swamp_y_min = -1;
          everness_cursed_lands_ocean = true;
          everness_cursed_lands_ocean_y_max = -2;
          everness_cursed_lands_ocean_y_min = -10;
          everness_cursed_lands_deep_ocean = true;
          everness_cursed_lands_deep_ocean_y_max = -11;
          everness_cursed_lands_deep_ocean_y_min = -62;
          everness_cursed_lands_under = true;
          everness_cursed_lands_under_y_max = -28939;
          everness_cursed_lands_under_y_min = -29067;
          everness_crystal_forest = true;
          everness_crystal_forest_y_max = 194;
          everness_crystal_forest_y_min = 6;
          everness_crystal_forest_dunes = true;
          everness_crystal_forest_dunes_y_max = 5;
          everness_crystal_forest_dunes_y_min = 1;
          everness_crystal_forest_shore = true;
          everness_crystal_forest_shore_y_max = 0;
          everness_crystal_forest_shore_y_min = -1;
          everness_crystal_forest_ocean = true;
          everness_crystal_forest_ocean_y_max = 2;
          everness_crystal_forest_ocean_y_min = -10;
          everness_crystal_forest_deep_ocean = true;
          everness_crystal_forest_deep_ocean_y_max = -11;
          everness_crystal_forest_deep_ocean_y_min = -62;
          everness_crystal_forest_under = true;
          everness_crystal_forest_under_y_max = -28939;
          everness_crystal_forest_under_y_min = -29067;
          everness_bamboo_forest = true;
          everness_bamboo_forest_y_max = 194;
          everness_bamboo_forest_y_min = 1;
          everness_bamboo_forest_under = true;
          everness_bamboo_forest_under_y_max = -28939;
          everness_bamboo_forest_under_y_min = -29067;
          everness_forsaken_desert = true;
          everness_forsaken_desert_y_max = 194;
          everness_forsaken_desert_y_min = 4;
          everness_forsaken_desert_ocean = true;
          everness_forsaken_desert_ocean_y_max = 3;
          everness_forsaken_desert_ocean_y_min = -8;
          everness_forsaken_desert_under = true;
          everness_forsaken_desert_under_y_max = -28939;
          everness_forsaken_desert_under_y_min = -29067;
          everness_baobab_savanna = true;
          everness_baobab_savanna_y_max = 194;
          everness_baobab_savanna_y_min = 1;
          everness_forsaken_tundra = true;
          everness_forsaken_tundra_y_max = 194;
          everness_forsaken_tundra_y_min = 2;
          everness_forsaken_tundra_beach = true;
          everness_forsaken_tundra_beach_y_max = 1;
          everness_forsaken_tundra_beach_y_min = -3;
          everness_forsaken_tundra_ocean = true;
          everness_forsaken_tundra_ocean_y_max = -4;
          everness_forsaken_tundra_ocean_y_min = -15;
          everness_forsaken_tundra_under = true;
          everness_forsaken_tundra_under_y_max = -28939;
          everness_forsaken_tundra_under_y_min = -29067;
          everness_feature_sneak_pickup = false;
          everness_feature_skybox = true;
        };
      };
    };
  };
  #services.minetest-server.enable = true;

  fileSystems."/mnt/desktop" = {
    device = "leonard@menzel.lol:/";
    fsType = "sshfs";
    options = [
      "allow_other"
      "nodev"
      "noatime"
      "IdentityFile=/home/leonard/.ssh/desktop"
    ];
  };

  virtualisation.vmware.host = {
    #enable = true;
    extraPackages = [ pkgs.ntfs3g ];
  };

  services.kubo = {
    enable = true;
    autoMount = true;
    localDiscovery = true;
    #extraFlags = [ "--revert-ok" ];
    package = inputs.pkgs-unstable.legacyPackages."x86_64-linux".kubo;
    enableGC = true;
    settings = {
      API.HTTPHeaders.Access-Control-Allow-Origin = [ "*" ];
      API.HTTPHeaders.Access-Control-Allow-Methods = [
        "GET"
        "POST"
        "PUT"
      ];
      Datastore.StorageMax = "200GB";
      Datastore.GCPeriod = "2h";
      Addresses.API = "/ip4/127.0.0.1/tcp/8082";
      Addresses.Gateway = "/ip4/0.0.0.0/tcp/8081";

    };
  };

  system.stateVersion = "23.11";

}
