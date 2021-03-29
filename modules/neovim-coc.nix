# See https://github.com/neoclide/coc.nvim
{ config, lib, ... }:
with lib;
let
  cfg = config.neovim.coc;
in rec {
  options.neovim.coc = {
    enable = mkEnableOption "Conquer of Completion";
    codeLens.enable = mkEnableOption "CodeLenses";
    virtualText.enable = mkEnableOption "Virtual text to display diagnostics" // {
      default = cfg.codeLens;
    };
    languageserver = mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = { };
      example = { nix = { command = "rnix-lsp"; filetypes = [ "nix" ]; }; };
    };
  };

  config = mkIf (cfg.enable && cfg.languageserver != {}) {
    xdg.configFile."nvim/coc-settings.json".text = builtins.toJSON {
      inherit (cfg) languageserver;
      codeLens = cfg.codeLens.enable;
      virtualText = cfg.codeLens.enable;
    };
  };
}
