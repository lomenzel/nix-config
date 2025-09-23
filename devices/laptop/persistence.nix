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
        ".config/kdeconnect"
        ".mozilla/firefox/default/storage"
        ".mozilla/firefox/default/extensions"
      ];
      files = [
        ".mozilla/firefox/default/storage.sqlite"
        ".mozilla/firefox/default/cookies.sqlite"
      ];
    };

  };
}