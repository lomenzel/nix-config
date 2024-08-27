{ config, pkgs, ... }:
{
  services.minecraft-server = {
    enable = true;
    eula = true;
    declarative = true;
    whitelist = {
      "Leonard_Menzel" = "46edb062-90ab-41e4-b443-33e668feb2f0";
      "Blumensky" = "ad5487ee-0e8e-4223-a218-1b34ed9d22d2";
      "_Eemes_" = "5748fa13-f93a-4795-adde-86c01d63e458";
      "Leni4603" = "5aa7fdbc-d116-4f44-9043-38a8b1c9c00b";
    };
    jvmOpts = "-Xms8000M -Xmx8000";
    serverProperties = {
      difficulty = "peaceful";
      white-list = false;
      simulation-distance = 32;
      view-distance = 32;
      enforce-whitelist = true;
      online-mode = false;
    };
  };
}
