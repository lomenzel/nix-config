{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../home-manager/programs/git.nix
    ../../home-manager/programs/vim.nix
  ];

  home.stateVersion = "24.05";
}
