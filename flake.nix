{
  description = "Cherry-picked components from ony's Nix configs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: {
    homeManagerModules = {
      neovim-coc = import ./home/modules/neovim-coc.nix;
      neovim-tree-sitter = import ./home/modules/neovim-tree-sitter.nix;
    };
  }
  //
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.pidgin-chime = pkgs.callPackage ./pkgs/pidgin-chime.nix { };
    });
}
