{ lib, config, ... }:
let
  inherit (lib) mkOption types;

  # We must not rely on self since we might be part of different flake than where we have our lib
  inherit (import ../lib { inherit lib; }) mkPkgDefs;

  pkgDefs = mkPkgDefs config.packagesOverlay;
  overlay = pkgDefs.toOverlay;

  overlayNodeType = types.oneOf [
    (types.functionTo (types.functionTo overlayNodeType))
    (types.lazyAttrsOf overlayNodeType)
    types.raw # TODO: derivation
  ];
in
{
  options = {
    packagesOverlay = mkOption {
      type = types.functionTo (types.lazyAttrsOf overlayNodeType);
      default = final0: { };
      description = ''
        Function from final/pkgs to hierarchy attrset of derivations/functions
        to be added to default overaly and packages/checks.
      '';
      example = lib.literalExpression ''
        (final0: {
          pkg = final0.callPackage ...;
          pkgset = {
            subpkg = final0.callPackage ...;
            subpkgset = { ... };
          };
          rewrittenset = (final: prev: { x = prev.y; y = mypkg { x = final.x; }; });
        })
      '';
    };
  };

  config = {
    flake.overlays.default = overlay;

    perSystem =
      { pkgs, ... }:
      let
        pkgs' = pkgs.extend overlay;
      in
      {
        packages = pkgDefs.toFlatPackages pkgs';
        checks = pkgDefs.toFlatPackages pkgs';
      };
  };
}
