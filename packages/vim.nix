{ inputs, system, ... }:
(inputs.nvf.lib.neovimConfiguration {
  pkgs = import inputs.nixpkgs-unstable { inherit system; };
  modules = [
    {
      config.vim = {
        # Enable custom theming options
        theme = {
          enable = true;
          name = "rose-pine";
          style = "main";
        };

        # Enable Treesitter
        treesitter.enable = true;
        languages = {
          nix.enable = true;
          haskell = {
            enable = true;
          };
        };
        terminal.toggleterm = {
          enable = true;
          lazygit.enable = true;
        };
        filetree.neo-tree = {
          enable = true;
        };

        # Other options will go here. Refer to the config
        # reference in Appendix B of the nvf manual.
        # ...
      };
    }
  ];
}).neovim
