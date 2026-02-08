{
  pkgs,
  config,
  inputs,
  ...
}:
{
  home.packages = with inputs.nixpkgs.legacyPackages."x86_64-linux".pkgsCross.armv7l-hf-multiplatform; [
    fractal
  ];
  home.stateVersion = "25.11";
}
