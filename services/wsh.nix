{ config, pkgs, ... }:
{
  services.wsh = {
    enable = true;

    host_mode = "local";
    configFile = pkgs.writeText "wsh-config.toml" ''
      prefix = "."


      [[sites]]
      name = "searxng"
      key = "lol"
      url = "https://search.menzel.lol/search?q={{s}}"
      [[sites]]
      name = "startpage"
      key = "s"
      alias = [ "startpage" ]
      url = "https://www.startpage.com/sp/search?query={{s}}"
      [[sites]]
      name = "google"
      key = "g"
      url = "https://www.google.de/search?q={{s}}"
      [[sites]]
      name = "duden"
      key = "d"
      url = "http://www.duden.de/suchen/dudenonline/{{s}}"
      [[sites]]
      name = "nixpkgs"
      key = "np"
      url = "https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query={{s}}"
      [[sites]]
      name = "nix options"
      key = "no"
      url = "https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query={{s}}"
      [[sites]]
      name = "wikipedia"
      key = "w"
      alias = [ "wiki" ]
      url = "https://de.wikipedia.org/wiki/Special:Search?search={{s}}"
      [[sites]]
      name = "kinox"
      key = "k"
      url = "https://kinox.to/Search.html?q={{s}}"
      [[sites]]
      name = "homemanageroptions"
      key = "h"
      url = "https://home-manager-options.extranix.com/?query={{s}}"
      [[sites]]
      name = "lernraum"
      key = "l"
      url = "https://lernraum.th-luebeck.de/my/courses.php{{s}}"
    '';
  };
}
