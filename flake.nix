{
  description = "Cherry-picked components from ony's Nix configs";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, flake-utils }: {
    overlay = final: prev: {
      pidgin-chime = final.pkgs.callPackage ./pkgs/pidgin-chime.nix { };
      nix-script-ruby = final.pkgs.writeScriptBin "nix-script-ruby"
        (builtins.readFile ./scripts/nix-script-ruby);
    };
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
      packages = {
        inherit (pkgs) pidgin-chime nix-script-ruby;
      };
    });
}
