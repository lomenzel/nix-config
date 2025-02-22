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
    #./jellyfin.nix
    #./kubo.nix
    ./mastodon.nix
    #./minecraft.nix
    #./searx.nix
    #./immich.nix
    ./ollama.nix
    #./nextcloud.nix
    ./matrix.nix
    ./anki.nix
    ./home.nix

    #testing    
    ./dailyMix/dailyMix.nix
    ./habitica.nix
    #./jitsi.nix
    ./comfy.nix
    #./mail.nix
    #./keycloak.nix
    #./hedgedoc.nix
    #./adguard.nix
    #./kasm.nix
    #./kubernetes.nix
    ./locationshare.nix

  ];

  services.k3s = {
    #enable = true;
    role = "agent";
    token = secrets.k3s.token;
    extraFlags = [
      #"--no-deploy traefik" # Disable Traefik
    ];
    serverAddr = "https://192.168.178.169:6443";
  };




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
        4444
        3457
        8080
        443
        8188
        9238
        27701
        25565
      ];
      allowedUDPPortRanges = [ kdeConnectPorts ];
    };
  services.fail2ban.enable = true;

}
