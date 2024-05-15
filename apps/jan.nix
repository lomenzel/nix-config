{ pkgs ? import <nixpkgs> { } }:

let appimageTools = pkgs.appimageTools;

in appimageTools.wrapType2 {
  name = "jan"; # Specify the name of the resulting image
  src = pkgs.fetchurl { # Fetch the AppImage file
    url =
      "https://github.com/janhq/jan/releases/download/v0.4.7/jan-linux-x86_64-0.4.7.AppImage";
    sha256 = "sha256-Mn7rIBEf46JbNof8h3z66TGdGKnb0FGMJc46JncA0KM=";
  };
  extraPkgs = pkgs: with pkgs; [ ]; # Additional packages to include (if needed)
}
