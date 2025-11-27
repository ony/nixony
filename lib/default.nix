{ lib }:
let
  inherit (builtins) mapAttrs isAttrs isFunction;
  inherit (lib.attrsets) isDerivation;

  # Converts attrset of shared form (pkgDefs):
  # lib.mkPkgDefs (final0: {
  #   pkg = final0.callPackage ...;
  #   pkgset = {
  #     subpkg = final0.callPackage ...;
  #     subpkgset = { ... };
  #   };
  #   rewrittenset = (final: prev: { x = prev.y; y = mypkg { x = final.x; }; });
  # })
  #
  # To be suitable for overlays section of Flake:
  # final: prev: {
  #   pkg = final.callPackage ...;
  #   pkgset = prev.pkgset.extend (_final: _prev: {
  #     subpkg = final.callPackage ...;
  #     subpkgset = prev'.subpkgset // { ... };
  #   });
  #   rewrittenset = { x = prev.rewritten.y; y = mypkg { x = final.rewritten.x; }; };
  # }
  #
  # Will use .extend when available.
  toOverlay = attrs@{ ... }: final: prev:
    let
      extendWith = final: prev: value:
        # will use wired in extend and fallback to just attrset override
        let prev_ = { extend = overlay: prev // overlay final prev; } // prev;
        in prev_.extend (toOverlay value);

      toValue = final: prev: name: value:
        if isFunction value then value final.${name} prev.${name}
        else if isDerivation value then value
        else if isAttrs value then extendWith final.${name} prev.${name} value
        else value;
    in mapAttrs (toValue final prev) attrs;

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
  mkPkgDefs = f: {
    toOverlay = final0: prev0: toOverlay (f final0) final0 prev0;
    toFlatPackages = pkgs: toFlatPackages (f pkgs) pkgs;
  };
}
