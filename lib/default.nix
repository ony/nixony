{ lib }:
let
  inherit (builtins) mapAttrs isAttrs isFunction;
  inherit (lib.attrsets) isDerivation;

  # Converts attrset of shared form (pkgDefs):
  # {
  #   pkg = final: final.pkgs.callPackage ...;
  #   pkgset = {
  #     subpkg = final: final.pkgs.callPackage ...;
  #     subpkgset = { ... };
  #   };
  # }
  #
  # To be suitable for overlays section of Flake:
  # final: prev: {
  #   pkg = final.pkgs.callPackage ...;
  #   pkgset = prev.pkgset // {
  #     subpkg = final.pkgs.callPackage ...;
  #     subpkgset = prev.pkgset.subpkgset // { ... };
  #   };
  # }
  toOverlay = attrs@{ ... }: final: prev:
    let
      walkIn = nestedPrev: attrs: mapAttrs (toValue nestedPrev) attrs;
      toValue = nestedPrev: name: value:
        if isFunction value then value final
        else if isDerivation value then value
        else if isAttrs value then nestedPrev.${name} // walkIn nestedPrev.${name} value
        else value;
    in walkIn prev attrs;

  # Cherr-pick packages defined in original pkgDefs from pkgs after applying overlay
  # Will replicate hierarchy from pkgDefs. E.g.
  # {
  #   pkg = ...;
  #   pkgset = {
  #     subpkg = ...;
  #     subpkgset = { ... };
  #   };
  # }
  toFlatPackages = attrs@{ ... }: pkgset:
    lib.concatMapAttrs (name: value:
      if isAttrs value && ! isDerivation value then toFlatPackages value pkgset.${name}
      else if pkgset.${name}.meta.broken then { }  # skip broken packages otherwise nix flake check will fail
      else { ${name} = pkgset.${name}; }
    ) attrs;

in {
  inherit toOverlay toFlatPackages;
}
