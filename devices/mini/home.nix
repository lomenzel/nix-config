{
  pkgs,
  config,
  ...
}:
{
  home.packages = with pkgs; [
    fractal
  ];
}
