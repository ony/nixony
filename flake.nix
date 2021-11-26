{
  description = "Cherry-picked components from ony's Nix configs";

  outputs = { self }: {
    homeManagerModules = {
      neovim-coc = import ./home/modules/neovim-coc.nix;
    };
  };
}
