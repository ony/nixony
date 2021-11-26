# See https://github.com/neoclide/coc.nvim
{ config, pkgs, lib ? pkgs.lib, ... }:
with lib;
let
  cfg = config.neovim.coc;
  managedSettings = {
    inherit (cfg) languageserver;
    "codeLens.enable" = cfg.codeLens.enable;
    "virtualText.enable" = cfg.virtualText.enable;
  };
  overrddenSettings = builtins.intersectAttrs managedSettings cfg.extraSettings;
in {
  options.neovim.coc = {
    enable = mkEnableOption "Conquer of Completion";

    pluginPackage = mkOption {
      type = types.package;
      default = pkgs.vimPlugins.coc-nvim;
      description = "coc-nvim package to use as plugin in neovim";
    };

    nodePackage = mkOption {
      type = types.package;
      default = pkgs.nodejs-slim_latest;
      description = "NodeJS package to use in neovim for coc plugin";
    };

    codeLens.enable = mkEnableOption "CodeLenses";
    virtualText.enable = mkEnableOption "VirtualText to display diagnostics" // {
      default = cfg.codeLens.enable;
    };

    languageserver = mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = { };
      example = { nix = { command = "rnix-lsp"; filetypes = [ "nix" ]; }; };
    };

    extraSettings = mkOption {
      type = lib.types.attrs;
      default = { };
      example = { "diagnostic.errorSign" = "✘"; };
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = cfg.codeLens.enable -> cfg.virtualText.enable;
      message = "CodeLenses feature require VirtualText";
    }];

    warnings = flatten [
      (optional (overrddenSettings != {})
      "neovim.coc.extraSettings clashing: ${builtins.toJSON overrddenSettings}")
      (optional (!config.programs.neovim.enable)
      "consider setting program.neovim.enable to true for neovim.coc to be effective")
    ];

    xdg.configFile."nvim/coc-settings.json".text =
      builtins.toJSON (managedSettings // cfg.extraSettings);

    programs.neovim.plugins = [ cfg.pluginPackage ];
    programs.neovim.extraPackages = mkIf (cfg.nodePackage != null) [
      cfg.nodePackage
    ];
  };
}
