{
  channels,
  inputs,
  ...
}: final: prev: {
  # the package to overlay is prev.internal.buildarr at python3.pkgs.buildarr
  python3 = prev.python3.override {
    packageOverrides = final: prev: {
      buildarr = prev.internal.buildarr;
    };
  };
}
