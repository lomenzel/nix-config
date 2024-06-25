{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "Leonard-Orlando Jonathan Menzel";
    userEmail = "leonard-orlando.jonathan.menzel@stud.th-luebeck.de";
    extraConfig = ''
      [save]
        directory = *
    '';
  };
}
