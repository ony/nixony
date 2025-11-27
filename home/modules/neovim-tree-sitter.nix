{ config, pkgs, lib ? pkgs.lib, ... }:
with lib;
let
  cfg = config.programs.neovim.tree-sitter;
in
{
  options.programs.neovim.tree-sitter = {
    enable = mkEnableOption "Enable tree-sitter integration";

    package = mkOption {
      type = types.package;
      default = pkgs.vimPlugins.nvim-treesitter;
      description = "Base nvim-treesitter plugin package that supports withPlugins";
    };

    finalPackage = mkOption {
      type = types.package;
      readOnly = true;
      description = "Resulting customized nvim-treesitter plugin package.";
    };

    type = mkOption {
      type = types.enum [ "viml" "lua" ];
      default = "viml";
      description = "language for config";
      example = literalExpression "lua";
    };

    config = mkOption {
      type = types.str;
      default = "";
      description = "VimL/Lua script for plugin initialization";
      example = literalExpression ''
        lua <<EOS
        require'nvim-treesitter.configs'.setup {
          highlight = {
            enable = true,
          },
        }
        EOS
      '';
    };

    grammarsView = mkOption {
      type = types.functionTo (types.listOf types.package);
      default = grammars: [ ];
      description = "Function to select wanted grammars";
      example = literalExpression ''
        grammars: with grammars; [ tree-sitter-nix ]
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.neovim.tree-sitter.finalPackage = cfg.package.withPlugins cfg.grammarsView;
    programs.neovim.plugins = [
      {
        plugin = cfg.finalPackage;
        inherit (cfg) type config;
      }
    ];
  };
}
