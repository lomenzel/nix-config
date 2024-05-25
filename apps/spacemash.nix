{ pkgs ? import <nixpkgs> }:
pkgs.stdenv.mkDerivation {
  pname = "go-spacemash";
  version = "0.1.0";

  src = builtins.fetchGit {
    url = "https://github.com/spacemeshos/go-spacemesh";
    ref = "v1.5.6";
}
;

  nativeBuildInputs = [ pkgs.go ];

  buildPhase = "
    make install
    make build
  ";

  installPhase = ''
    mkdir -p $out/bin
    cp . $out/bin

  '';
}

