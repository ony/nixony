{
  description = "Cherry-picked components from ony's Nix configs";

  inputs = {
    import-tree.url = "github:vic/import-tree";

    home-manager.url = "flake:home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-parts,
      systems,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.home-manager.flakeModules.home-manager
        (inputs.import-tree ./modules)
      ];

      flake = {
        homeModules = {
          neovim-coc = import ./home/modules/neovim-coc.nix;
          neovim-tree-sitter = import ./home/modules/neovim-tree-sitter.nix;
        };
      };

      systems = import systems;
    };
}
