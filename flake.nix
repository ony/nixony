{
  description = "Cherry-picked components from ony's Nix configs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
  let
    inherit (builtins) mapAttrs isAttrs isFunction;
    inherit (nixpkgs.lib.attrsets) isDerivation concatMapAttrs;

    # Converts attrset of form:
    # {
    #   pkg = final: final.pkgs.callPackage ...;
    #   pkgset = {
    #     subpkg = final: final.pkgs.callPackage ...;
    #     subpkgset = { ... };
    #   };
    # }
    # To:
    # final: prev: {
    #   pkg = final.pkgs.callPackage ...;
    #   pkgset = prev.pkgset // {
    #     subpkg = final.pkgs.callPackage ...;
    #     subpkgset = prev.pkgset.subpkgset // { ... };
    #   };
    # }
    toOverlay = attrs@{...}: final: prev:
      let
        walkIn = nestedPrev: attrs: mapAttrs (toValue nestedPrev) attrs;
        toValue = nestedPrev: name: value:
          if isFunction value then value final
          else if isDerivation value then value
          else if isAttrs value then nestedPrev.${name} // walkIn nestedPrev.${name} value
          else value;
      in walkIn prev attrs;

    toPackages = attrs@{...}: pkgset:
      mapAttrs (name: value:
          if isAttrs value && ! isDerivation value then toPackages value pkgset.${name}
          else pkgset.${name}
      ) attrs;

    pkgDefs = {
      unionfarm = final: final.pkgs.callPackage ./pkgs/unionfarm.nix { };
      pidgin-chime = final: final.pkgs.callPackage ./pkgs/pidgin-chime.nix { };
      overlayfs-tools = final: final.pkgs.callPackage ./pkgs/overlayfs-tools.nix { };
      nix-script-ruby = final: final.pkgs.writeScriptBin "nix-script-ruby"
        (builtins.readFile ./scripts/nix-script-ruby);

      vimPlugins = {
        nvim-treesitter-playground = final: final.pkgs.vimUtils.buildVimPlugin {
          name = "nvim-treesitter-playground";
          src = final.pkgs.fetchFromGitHub {
            owner = "nvim-treesitter";
            repo = "playground";
            rev = "787a7a8d4444e58467d6b3d4b88a497e7d494643";
            hash = "sha256-YMINv064VzuzZLuQNY6HN3oCZvYjNQi6IMliQPTijfg=";
          };
        };

        nvim-spellsitter = final: final.pkgs.vimUtils.buildVimPlugin {
          name = "nvim-spellsitter";
          dontBuild = true;
          src = final.pkgs.fetchFromGitHub {
            owner = "lewis6991";
            repo = "spellsitter.nvim";
            rev = "3458915f9cccc7a4c95f272793790628fcd49bf7";
            hash = "sha256-Tedv5x35MuLftWg0q8bYMM7Jhw7dMImeFP90IfdfJuY=";
          };
        };
      };
    };
  in {
    overlay = toOverlay pkgDefs;
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
      packages = toPackages pkgDefs pkgs;
    });
}
