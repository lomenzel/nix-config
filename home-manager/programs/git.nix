{
  config,
  pkgs-self,
  ...
}:
{
  programs.git = {
    enable = true;
    userName = "Leonard-Orlando Jonathan Menzel";
    userEmail = "leonard-orlando.jonathan.menzel@stud.th-luebeck.de";
    extraConfig = {
      save.directory = "*";
      core.editor = "${pkgs-self.vim}/bin/nvim";
      pull.rebase = true;
      credential.helper = "store";
    };
  };
}
