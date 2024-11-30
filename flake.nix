{
  description = "Cherry-picked components from ony's Nix configs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: {
    overlay = final: prev: {
      pidgin-chime = final.pkgs.callPackage ./pkgs/pidgin-chime.nix { };
      nix-script-ruby = final.pkgs.writeScriptBin "nix-script-ruby"
        (builtins.readFile ./scripts/nix-script-ruby);

      vimPlugins = prev.vimPlugins // {
        nvim-treesitter-playground = final.pkgs.vimUtils.buildVimPlugin {
          name = "nvim-treesitter-playground";
          src = final.pkgs.fetchFromGitHub {
            owner = "nvim-treesitter";
            repo = "playground";
            rev = "787a7a8d4444e58467d6b3d4b88a497e7d494643";
            hash = "sha256-YMINv064VzuzZLuQNY6HN3oCZvYjNQi6IMliQPTijfg=";
          };
        };

        nvim-spellsitter = final.pkgs.vimUtils.buildVimPlugin {
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
        inherit (pkgs) unionfarm pidgin-chime nix-script-ruby;
        vimPlugins = {
          inherit (pkgs.vimPlugins)
            nvim-treesitter-playground
            nvim-spellsitter;
        };
      };
    });
}
