{...}:{
  environment.persistence."/persistent" =  {

    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
    ];
    users.leonard = {
      directories = [
        "Bilder"
        "Dokumente"
        "Musik"
        "Videos"
        ".local/share/direnv"
        ".config/nix-config"
      ];
      files = [
        ".config/sops/age/keys.txt"
      ];
    };

  };
}