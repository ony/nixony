{
  description = "Cherry-picked components from ony's Nix configs";

  inputs.flake-parts.url = "flake:flake-parts";
  inputs.systems.url = "flake:systems";
  inputs.home-manager.url = "flake:home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs@{ self, nixpkgs, ... }:
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
        nvim-spellsitter = nixpkgsAdopted "nvim-spellsitter" ["vimPlugins" "spellsitter-nvim"] final0;
      };
    });
  in inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      inputs.home-manager.flakeModules.home-manager

      # https://flake.parts/overlays.html?highlight=overlay#consuming-an-overlay
      {
        perSystem = { system, ... }: {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
            config = { };
          };
        };
      }
    ];

    flake = {
      inherit lib;
      overlays.default = pkgDefs.toOverlay;
      homeModules = {
        neovim-coc = import ./home/modules/neovim-coc.nix;
        neovim-tree-sitter = import ./home/modules/neovim-tree-sitter.nix;
      };
    };

    systems = import inputs.systems;

    perSystem = { pkgs, ... }: {
      packages = pkgDefs.toFlatPackages pkgs;
      checks = pkgDefs.toFlatPackages pkgs;
    };
  };
}
