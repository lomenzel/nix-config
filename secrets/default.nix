{
  config,
  inputs,
  lib,
  options,
  ...
}:
{
  imports = lib.singleton inputs.sops-nix.nixosModules.sops;
  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/persistent/sops-key.txt";
    secrets = {
      "programs/anki/sync_key".owner = "leonard";
      "extern/inwx/username".owner = lib.mkIf (builtins.hasAttr "inwx-dns" options.services && config.services.inwx-dns.enable)  config.services.inwx-dns.user;
      "extern/inwx/password".owner = lib.mkIf (builtins.hasAttr "inwx-dns" options.services && config.services.inwx-dns.enable)  config.services.inwx-dns.user;
      "services/immich/apiKey".owner = "leonard";
      "devices/password".neededForUsers = true;
    };
    templates."inwx-secrets"  = {
      content = ''
        INWX_USERNAME=${config.sops.placeholder."extern/inwx/username"}
        INWX_PASSWORD=${config.sops.placeholder."extern/inwx/password"}
      '';
      owner = lib.mkIf (config.security.acme.certs != {}) "acme";
    };
  };

  services.inwx-dns = lib.mkIf (builtins.hasAttr "inwx-dns" options.services && config.services.inwx-dns.enable) {
    inwx-username-file = config.sops.secrets."extern/inwx/username".path;
    inwx-password-file = config.sops.secrets."extern/inwx/password".path;
  };

  users.users.leonard.hashedPasswordFile = config.sops.secrets."devices/password".path;

  security.acme.defaults.credentialsFile = config.sops.templates.inwx-secrets.path;

}
