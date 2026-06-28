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
        flake-parts.flakeModules.flakeModules
        (inputs.import-tree ./modules)
      ];

      flake = {
        homeModules = {
          neovim-coc = import ./home/modules/neovim-coc.nix;
          neovim-tree-sitter = import ./home/modules/neovim-tree-sitter.nix;
        };

        # https://flake.parts/dogfood-a-reusable-module.html
        flakeModules.packagesOverlay = ./modules/flake-module-packagesOverlay.nix;
        flakeModules.default = inputs.self.flakeModules.packagesOverlay;
      };

      systems = import systems;
    };
}
