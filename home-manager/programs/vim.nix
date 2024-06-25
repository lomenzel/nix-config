{ config, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    extraConfig = ''
      set number
      set autowriteall
      lua << EOF
         require("otter").activate({ "javascript", "python" }, true, true, nil)
      EOF
    '';
    plugins = with pkgs.vimPlugins; [ otter-nvim ];
    vimAlias = true;
    viAlias = true;
  };
}
