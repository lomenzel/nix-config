{ config, pkgs, secrets, ... }:
let

  music-py = pkgs.python312.withPackages (
    ps: with ps; [
      pandas
      requests
      python-dotenv
      numpy
    ]
  );

  jellyfin-music =
  let
    env_file = pkgs.writeText ".env" ''
      # needed for all scripts
      API_KEY=${secrets.jellyfin.api-key}
      JELLYFIN_IP=https://media.menzel.lol

      # needed for jellyfin_music.py
      USER_NAME=leonard
      PLAYLIST_LENGTH=3  # Length of the playlist in hours
      PLAYLIST_NAME=Leonard Daily Mix

      # needed for jellyfin_based_shutdown.py
      #WAKEUP_TIME=07:00  # 24 hour format
    '';
  in
   pkgs.mkDerivation {
    pname = "jellyfin-music";
    version = "1.0";
    src = ./.;
    installPhase = ''
      mkdir -p $out
      cp $src/jellyfin_music.py $out/jellyfin_music.py
      cp ${env_file} $out/.env
    '';
  };



in
{

  systemd.timers."daily-mix" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
    };
  };
  systemd.services."daily-mix" = {
    script = ''
      ${music-py}/bin/python ./jellyfin_music.py
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "leonard";
    };
    WorkingDirectory = "${jellyfin-music}";
  };
}
