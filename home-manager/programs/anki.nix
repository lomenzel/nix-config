{
  pkgs-unstable,
  config,
  secrets,
  ...
}:
{

  programs.anki = {
    enable = true;
    style = "native";
    package = pkgs-unstable.anki;
    sync = {
      autoSync = true;
      autoSyncMediaMinutes = 2;
      syncMedia = true;
      url = "https://anki.menzel.lol";
      username = "leonard";
      passwordFile =  secrets."programs/anki/sync_key".path;
    };
    theme = "followSystem";
    language = "eo_UY";

    minimalistMode = true;

    addons = with pkgs-unstable.ankiAddons; [
      (
        (pkgs-unstable.anki-utils.buildAnkiAddon (finalAttrs: rec {
          pname = "puppy-reinforcement";
          version = "1.1.1";
          src = pkgs-unstable.fetchFromGitHub {
            owner = "glutanimate";
            repo = "puppy-reinforcement";
            rev = "v${version}";
            hash = "sha256-y52AjmYrFTcTwd4QAcJzK5R9wwxUSlvnN3C2O/r5cHk=";
          };
          sourceRoot = "${finalAttrs.src.name}/src/puppy_reinforcement";
        })).withConfig
        {
          config = {
            count_adding = false;
            count_reviewing = true;
            disable_default_images = true;
            duration = 3000;
            encourage_every = 10;
            image_height = 512;
            limit_high = 50;
            limit_max = 100;
            limit_middle = 25;
            max_spread = 5;
            reset_counter_on_new_day = true;
            tooltip_align_horizontal = "left";
            tooltip_align_vertical = "bottom";
            tooltip_color = "#f157f1";
            tooltip_space_horizontal = 0;
            tooltip_space_vertical = 100;
          };
        }
      )
    ];

  };
}
