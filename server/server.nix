{ config
, pkgs
, secrets
, ...
}:
let
  sshKey = secrets.ssh.keys.laptop;
in
{
  imports = [
    #helpers
    ./nginx.nix
    ./docker.nix
    ./acme.nix

    #working
    ./gitlab.nix
    ./jellyfin.nix
    ./kubo.nix
    ./mastodon.nix
    #./minecraft.nix
    ./searx.nix
    ./habitica.nix
    ./immich.nix
    ./ollama.nix
    ./nextcloud.nix
    ./matrix.nix
    ./anki.nix
    ./home.nix
    ./matrix.nix

    #testing
    #./jitsi.nix
    ./comfy.nix
    #./mail.nix
    ./keycloak.nix
    #./hedgedoc.nix
    #./adguard.nix
    #./kasm.nix
    #./kubernetes.nix

  ];

  #Security
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
    };
  };

  users.users."leonard".openssh.authorizedKeys.keys = [ "ssh-ed25519 ${sshKey} leonard" ];

  networking.firewall =
    let
      kdeConnectPorts = {
        from = 1714;
        to = 1764;
      };
    in
    {
      allowedTCPPorts = [
        22
        25
        53
        80
        143
        443
        465
        587
        993
        8080
        25565
      ];
      allowedTCPPortRanges = [ kdeConnectPorts ];
      allowedUDPPorts = [
        53
        80
        8080
        443
        25565
      ];
      allowedUDPPortRanges = [ kdeConnectPorts ];
    };
  services.fail2ban.enable = true;

}
