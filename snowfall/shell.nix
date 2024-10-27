{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # All other arguments come from NixPkgs. You can use `pkgs` to pull shells or helpers
  # programmatically or you may add the named attributes as arguments here.
  pkgs,
  mkShell,
  ...
}:
mkShell {
  # Create your shell
  packages = with pkgs; [
    alejandra
    direnv
    git
    gh
    inotify-tools
    nix-direnv
    nix-output-monitor
    parallel
    mdbook
    pandoc
    shellcheck
    pre-commit
    btop
    shfmt
    manix
    deadnix
  ];
}
