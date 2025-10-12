{ rustPlatform, fetchCrate, lib }:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ion-cli";
  version = "0.11.0";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-MCyEW8TS9VaeaEsnzu7Kivm2mNu7AxpE+sgo+yA7gyU=";
  };

  cargoHash = "sha256-HhwxFYHi4dcaDsNfL2buIjVQ5TrDMpszk2DC9WxoFNA=";

  checkFlags = [
    # failed to execute 'cargo clean': Os { code: 2, kind: NotFound, message: "No such file or directory" }
    "--skip=roundtrip_tests_for_generated_code_cargo"

    # Attempt to inject Gradle from nixpkgs it still fails on missing foojay-resolver-convention
    "--skip=roundtrip_tests_for_generated_code_gradle"
  ];

  meta = {
    description = "Command line tool for working with the Ion data format.";
    homepage = "https://amazon-ion.github.io/ion-docs/libs.html";
    license = lib.licenses.asl20;
  };
})
