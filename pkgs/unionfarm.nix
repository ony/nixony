{ rustPlatform, fetchCrate, lib }:
rustPlatform.buildRustPackage rec {
  pname = "unionfarm";
  version = "0.1.6";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-7SH1u+4dtDtVNTiTjRNne7TiG1AFcHn6m8n06g93asU=";
  };

  cargoHash = "sha256-3BSwaVFFA1SP9AG3KpRXUkspfeb36JUnLwLxQGVBo1s=";
  meta = {
    description = "A small utility for managing symlink farms";
    longDescription = ''
      This is a small utility for managing symlink farms. It takes a "farm"
      directory and any number of "data" directories, and creates (or updates)
      the union (or overlay) of the data directories in the farm directory by
      placing symlinks to data directories.
    '';
    homepage = "";
    license = lib.licenses.gpl3Plus;
  };
}
