{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    #./programs/firefox.nix
    ./programs/git.nix
    ./programs/vim.nix
    #./plasma.nix
    #inputs.plasma-manager.homeManagerModules.plasma-manager
    #./programs/vscode.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  #services.activitywatch.enable = true;

  home.username = "leonard";
  home.homeDirectory = "/home/leonard";
  home.stateVersion = "24.05";
}
