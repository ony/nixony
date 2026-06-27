{ self, inputs, ... }:
let
  inherit (self) lib;

  pkgsDir = "${self}/pkgs";

  nixpkgsAdopted =
    oldName: path: final0:
    final0.lib.warnOnInstantiate "${oldName} now present in nixpkgs as ${final0.lib.concatStringsSep "." path}" (
      final0.lib.getAttrFromPath path final0.pkgs
    );

  pkgDefs = lib.mkPkgDefs (final0: {
    unionfarm = final0.callPackage "${pkgsDir}/unionfarm.nix" { };
    pidgin-chime = final0.callPackage "${pkgsDir}/pidgin-chime.nix" { };
    overlayfs-tools = final0.callPackage "${pkgsDir}/overlayfs-tools.nix" { };
    nix-script-ruby = final0.writeScriptBin "nix-script-ruby" (
      builtins.readFile "${self}/scripts/nix-script-ruby"
    );
    ion-cli = final0.callPackage "${pkgsDir}/ion-cli.nix" { };

    vimPlugins = {
      nvim-spellsitter = nixpkgsAdopted "nvim-spellsitter" [ "vimPlugins" "spellsitter-nvim" ] final0;
    };
  });
in
{
  flake.overlays.default = pkgDefs.toOverlay;

  perSystem =
    { system, pkgs, ... }:
    {
      # https://flake.parts/overlays.html?highlight=overlay#consuming-an-overlay
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
        config = { };
      };

      packages = pkgDefs.toFlatPackages pkgs;
      checks = pkgDefs.toFlatPackages pkgs;
    };
}
