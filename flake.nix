{
  description = "Cherry-picked components from ony's Nix configs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
  let
    lib = import ./lib { inherit (nixpkgs) lib; };

    nixpkgsAdopted = oldName: path: final0: final0.lib.warnOnInstantiate
      "${oldName} now present in nixpkgs as ${final0.lib.concatStringsSep "." path}"
      (final0.lib.getAttrFromPath path final0.pkgs);

    pkgDefs = lib.mkPkgDefs (final0: {
      unionfarm = final0.callPackage ./pkgs/unionfarm.nix { };
      pidgin-chime = final0.callPackage ./pkgs/pidgin-chime.nix { };
      overlayfs-tools = final0.callPackage ./pkgs/overlayfs-tools.nix { };
      nix-script-ruby = final0.writeScriptBin "nix-script-ruby"
        (builtins.readFile ./scripts/nix-script-ruby);
      ion-cli = final0.callPackage ./pkgs/ion-cli.nix { };

      vimPlugins = {
        nvim-treesitter-playground = nixpkgsAdopted "nvim-treesitter-playground" ["vimPlugins" "playground"] final0;
        nvim-spellsitter = nixpkgsAdopted "nvim-spellsitter" ["vimPlugins" "spellsitter-nvim"] final0;
      };
    });
  in {
    inherit lib;
    overlay = pkgDefs.toOverlay;
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
      packages = pkgDefs.toFlatPackages pkgs;
      checks = pkgDefs.toFlatPackages pkgs;
    });
}
