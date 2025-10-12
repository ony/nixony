{
  description = "Cherry-picked components from ony's Nix configs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
  let
    lib = import ./lib { inherit (nixpkgs) lib; };

    nixpkgsAdopted = oldName: path: final: final.lib.warnOnInstantiate
      "${oldName} now present in nixpkgs as ${final.lib.concatStringsSep "." path}"
      (final.lib.getAttrFromPath path final.pkgs);

    pkgDefs = {
      unionfarm = final: final.pkgs.callPackage ./pkgs/unionfarm.nix { };
      pidgin-chime = final: final.pkgs.callPackage ./pkgs/pidgin-chime.nix { };
      overlayfs-tools = final: final.pkgs.callPackage ./pkgs/overlayfs-tools.nix { };
      nix-script-ruby = final: final.pkgs.writeScriptBin "nix-script-ruby"
        (builtins.readFile ./scripts/nix-script-ruby);

      vimPlugins = {
        nvim-treesitter-playground = nixpkgsAdopted "nvim-treesitter-playground" ["vimPlugins" "playground"];
        nvim-spellsitter = nixpkgsAdopted "nvim-spellsitter" ["vimPlugins" "spellsitter-nvim"];
      };
    };
  in {
    inherit lib;
    overlay = lib.toOverlay pkgDefs;
    homeManagerModules = {
      neovim-coc = import ./home/modules/neovim-coc.nix;
      neovim-tree-sitter = import ./home/modules/neovim-tree-sitter.nix;
    };
  } // flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      };
    in
    {
      packages = lib.toFlatPackages pkgDefs pkgs;
      checks = lib.toFlatPackages pkgDefs pkgs;
    });
}
