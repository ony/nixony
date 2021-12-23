# See https://github.com/neoclide/coc.nvim
{ config, pkgs, lib ? pkgs.lib, ... }:
with lib;
let
  oldCfg = config.neovim.coc;
  cfg = config.programs.neovim.coc;
  managedSettings = {
    inherit (oldCfg) languageserver;
    "codeLens.enable" = oldCfg.codeLens.enable;
    "virtualText.enable" = oldCfg.virtualText.enable;
  };
  overrddenSettings = builtins.intersectAttrs managedSettings oldCfg.extraSettings;
  sharedOptions = {
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
  };
in
{
  options.programs.neovim.coc = sharedOptions;
  options.neovim.coc = sharedOptions // {
    enable = mkEnableOption "Conquer of Completion";

    codeLens.enable = mkEnableOption "CodeLenses";
    virtualText.enable = mkEnableOption "VirtualText to display diagnostics" // {
      default = oldCfg.codeLens.enable;
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

  config = {
    assertions = [{
      assertion = oldCfg.enable && oldCfg.codeLens.enable -> oldCfg.virtualText.enable;
      message = "CodeLenses feature require VirtualText";
    }];

    warnings = flatten [
      (optional oldCfg.enable
        "Use programs.neovim.coc instead of neovim.coc")
      (optional (oldCfg.enable && overrddenSettings != { })
        "neovim.coc.extraSettings clashing: ${builtins.toJSON overrddenSettings}")
    ];

    programs.neovim.coc = mkIf oldCfg.enable {
      enable = true;
      settings = managedSettings // oldCfg.extraSettings;
    };

    # Even that HM includes adding coc-nvim plugin, it is not effective from there.
    programs.neovim.plugins = optionals cfg.enable [ oldCfg.pluginPackage ];

    # coc uses javascript
    programs.neovim.extraPackages = optionals (cfg.enable && cfg.nodePackage != null) [
      oldCfg.nodePackage
    ];
  };
}
