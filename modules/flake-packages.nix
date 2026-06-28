{ self, ... }:
let
  pkgsDir = "${self}/pkgs";

  nixpkgsAdopted =
    oldName: path: final0:
    final0.lib.warnOnInstantiate "${oldName} now present in nixpkgs as ${final0.lib.concatStringsSep "." path}" (
      final0.lib.getAttrFromPath path final0.pkgs
    );
in
{
  packagesOverlay = final0: {
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
  };
}
