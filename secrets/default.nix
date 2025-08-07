{
  inputs,
  lib,
  ...
}: {
  imports = lib.singleton inputs.sops-nix.nixosModules.sops;
  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/leonard/.config/sops/age/keys.txt";
    secrets = {
      "programs/anki/sync_key" = {
        owner = "leonard";
      };
    };
  };
}
