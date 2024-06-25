{ config, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    configure = {
      customRC = ''
        set number
        set autowriteall
        lua << EOF
           require("otter").activate({ "javascript", "python" }, true, true, nil)
        EOF
      '';
    };
    plugins = with pkgs.vimPlugins; [
      otter-nvim
    ];
    vimAlias = true;
    viAlias = true;
  };
}
