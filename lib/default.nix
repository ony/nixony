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
  #   pkgset = prev.pkgset.extend (_final: _prev: {
  #     subpkg = final.pkgs.callPackage ...;
  #     subpkgset = prev'.subpkgset // { ... };
  #   });
  # }
  #
  # Will use .extend when available.
  toOverlay = attrs@{ ... }: final0: prev0:
    let
      extendWith = prev: value:
        # will use wired in extend and fallback to just attrset override
        let prev' = { extend = overlay: prev // overlay (assert false; {}) prev; } // prev;
        in prev'.extend (_: prev'': walkIn prev'' value);

      walkIn = prev: attrs: mapAttrs (toValue prev) attrs;
      toValue = prev: name: value:
        if isFunction value then value final0
        else if isDerivation value then value
        else if isAttrs value then extendWith prev.${name} value
        else value;
    in walkIn prev0 attrs;

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
