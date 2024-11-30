{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  musl-fts,
  sudo,
}:
let
  pname = "overlayfs-tools";
  version = "2024.07";
in
stdenv.mkDerivation {
  inherit pname version;

  buildInputs = [ meson ninja pkg-config sudo ];
  propagatedBuildInputs = [ musl-fts ];

  testPhase = false; # requires sudo

  src = fetchFromGitHub {
    owner = "kmxz";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-3LgUmlIymWNAWWo6/4TRMRP5jOeAYc/BQRTJ8rk8be0=";
  };

  meta = {
    description = "Maintenance tools for overlay-filesystem";
    longDescription = ''
      Provides:
      - `fsck.overlay` check/repair underlying directories.
      - `overlay vacuum` removes duplicates in upper layer.
      - `overlay diff` to show changes from lower layer.
      - `overlay merge` to push changes down to lower layer.
      - `overlay deref` creates copy of upper layer compatible with legacy overlayfs.
    '';
    license = lib.licenses.wtfpl;
  };
}
