{
  inputs,
  system,
  ...
}:
(inputs.nvf.lib.neovimConfiguration {
  pkgs = import inputs.nixpkgs-unstable {inherit system;};
  modules = [
    {
      config.vim = {
        diagnostics = {
          enable = true;
          config = {
            # update_in_insert = true;
            virtual_lines.current_line = true;
            virtual_text = true;
          };
        };
        # Enable custom theming options
        theme = {
          enable = true;
          name = "rose-pine";
          style = "main";
        };

        spellcheck.enable = true;
        keymaps = [
          {
            key = "<M-CR>";
            mode = "n";
            silent = true;
            action = "<cmd> lua vim.lsp.buf.code_action()<CR>";
          }
        ];

        tabline.nvimBufferline.enable = true;
        minimap.codewindow.enable = true;
        telescope.enable = true;
        notify.nvim-notify.enable = true;
        lsp = {
          enable = true;
          formatOnSave = true;
          inlayHints.enable = true;
          lightbulb = {
            enable = true;
            autocmd.enable = true;
          };
          otter-nvim.enable = true;
          nvim-docs-view.enable = true;
        };

        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
          hardtime-nvim.enable = true;
        };

        # Enable Treesitter
        treesitter.enable = true;
        languages = {
          enableFormat = true;
          enableTreesitter = true;
          nix.enable = true;
          haskell = {
            enable = true;
          };
        };
        visuals = {
          nvim-cursorline.enable = true;
          nvim-scrollbar.enable = true;
        };

        utility = {
          motion = {
            hop.enable = true;
            leap.enable = true;
            precognition.enable = true;
          };
        };

        ui = {
          borders.enable = true;
          noice.enable = true;
          colorizer.enable = true;
          illuminate.enable = true;
          breadcrumbs = {
            enable = true;
            navbuddy.enable = true;
          };
        };

        assistant.avante-nvim.enable = true;

        statusline = {
          lualine.enable = true;
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
