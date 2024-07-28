{
  config,
  pkgs,
  secrets,
  ...
}:
let
  sshKey = secrets.ssh.keys.laptop;
in
{
  imports = [
    #helpers
    ./nginx.nix
    ./acme.nix

    #working
    #./gitlab.nix
    ./jellyfin.nix
    ./kubo.nix
    ./mastodon.nix
    ./minecraft.nix

    #testing
    #./matrix.nix
    ./jitsi.nix
    ./comfy.nix
    ./searx.nix
    ./ollama.nix
    ./nextcloud.nix

    #./cookie/cookie.nix
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
        80
        443
        8080
        25565
      ];
      allowedTCPPortRanges = [ kdeConnectPorts ];
      allowedUDPPorts = [
        80
        8080
        443
        25565
      ];
      allowedUDPPortRanges = [ kdeConnectPorts ];
    };
  services.fail2ban.enable = true;

}
