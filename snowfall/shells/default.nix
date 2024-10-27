{
  pkgs,
  mkShell,
  ...
}:
mkShell {
  # Create your shell
  packages = with pkgs; [
    alejandra
    btop
    deadnix
    direnv
    gh
    git
    inotify-tools
    manix
    mdbook
    nix-direnv
    nix-output-monitor
    pandoc
    parallel
    pre-commit
    shellcheck
    shfmt
  ];
}
