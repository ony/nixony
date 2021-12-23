## Usage

Example:
```nix
{
  home-manager.url = "github:nix-community/home-manager";
  nixony.url = "github:ony/nixony";
  nix-script.url = "github:BrianHicks/nix-script";  # if you use nix-script-* packages

  outputs = { home-manager, nix-script, nixony, ... }: {
    homeConfigurations.smith = home-manager.lib.homeManagerConfiguration {
      configuration = {
        imports = [
          nixony.homeManagerModules.neovim-tree-sitter
          ./home.nix
        ];

        nixpkgs.overlays = [
          nix-script.overlay
          nixony.overlay  # brings packages like pidgin-chime and nix-script-ruby
        ];

        # ...
      };

      # ...
    };
  };
}
```

Note that scripts like `nix-script-ruby` may require `nix-script` (from
`BrianHicks/nix-script`) to be visible in your `$PATH` be it user or
system-wide.
