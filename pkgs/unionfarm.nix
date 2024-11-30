{ rustPlatform, fetchCrate, lib }:
rustPlatform.buildRustPackage rec {
  pname = "unionfarm";
  version = "0.1.5";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-5U1CRRuAaG4LJG92Ub/Wa6KaSzNLmXZhxEv4x/+wOoE=";
  };

  cargoHash = "sha256-YjOpGRwl1ZkTMG4w149ywtB7VR1TQvEx98DCfkbNTnY=";
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
