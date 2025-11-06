{
  config,
  pkgs,
  legacy_secrets,
  ...
}:
let
  sshKey = legacy_secrets.ssh.keys.laptop;
in
{
  imports = [
    #helpers
    ./nginx.nix
    ./docker.nix
    ./acme.nix

    #working
    ./gitlab.nix
    #./jellyfin.nix
    #./kubo.nix
    ./mastodon.nix
    #./minecraft.nix
    #./searx.nix
    #./immich.nix
    #./ollama.nix
    #./nextcloud.nix
    ./matrix.nix
    #./anki.nix
    #./home.nix

    #testing
    ./luanti.nix
    ./dailyMix/dailyMix.nix
    #./habitica.nix
    #./jitsi.nix
    #./comfy.nix
    #./mail.nix
    #./keycloak.nix
    #./hedgedoc.nix
    #./adguard.nix
    #./kasm.nix
    #./kubernetes.nix
    #./locationshare.nix

  ];

  #Security
  services.openssh = {
    enable = true;
    allowSFTP = true;
    settings = {
      PermitRootLogin = "no";
    };
  };

  users.users."leonard".openssh.authorizedKeys.keys = [
    "ssh-ed25519 ${sshKey} leonard"
    "ssh-ed25519 ${sshKey} root"
  ];

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
        2049
        4444
        8080
        3500
        3501
        3457
        25565
        8123
        8008
        8281
        8100
        8188
        9238
        27701
        55001
      ];
      allowedTCPPortRanges = [ kdeConnectPorts ];
      allowedUDPPorts = [
        53
        80
        2049
        4444
        3457
        8080
        443
        8188
        9238
        27701
        25565
      ];
      allowedUDPPortRanges = [
        kdeConnectPorts
        {
          from = 30000;
          to = 30200;
        }
      ];
    };
  services.fail2ban.enable = true;

}
