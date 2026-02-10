{
  pkgs,
  config,
  inputs,
  pkgs-cross,
  ...
}:
{
  home.packages = with pkgs-cross; [
    pkgs.hello
    fractal
  ];
  home.username = "leonard";
  home.homeDirectory = "/home/leonard";
  home.stateVersion = "26.05";
}
