{ pkgs ? import <nixpkgs> }:
pkgs.stdenv.mkDerivation rec {
  pname = "cookie";
  version = "0.1.0";

  src = pkgs.fetchgit {
    url =
      "https://git.mylab.th-luebeck.de/ux-cookie-banner/uex-cookie-banner-website";
    hash = "sha256-esFRIeck+ZYL0iqNwlrSL112g6Xq6TYEHMIzpomk8bs="
  };

  nativeBuildInputs = [ pkgs.nodejs ];

  buildPhase = "\n";

  installPhase = ''
    mkdir -p $out/bin

    mv ./public $out/public

    mv ./db.json $out
  '';
}

