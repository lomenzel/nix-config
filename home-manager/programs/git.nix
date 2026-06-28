{
  config,
  pkgs-self,
  ...
}:
{
  programs.git = {
    enable = true;
    settings = {
      save.directory = "*";
      core.editor = "${pkgs-self.vim}/bin/nvim";
      pull.rebase = true;
      credential.helper = "store";
      user = {
        email = "leonard@menzel.lol";
        name = "Leonard-Orlando Jonathan Menzel";
      };
    };
  };
}
