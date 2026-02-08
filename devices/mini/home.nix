{
  pkgs,
  config,
  inputs,
  ...
}:
{
  home.packages = with inputs.nixpkgs-unstable.legacyPackages."x86_64-linux".pkgsCross.armv7l-hf-multiplatform; [
    fractal
  ];
  home.username = "leonard";
  home.homeDirectory = "/home/leonard";
  home.stateVersion = "25.11";
}
