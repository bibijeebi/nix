final: prev: {
  python3Packages =
    prev.python3Packages.override { overrides = [ (import ./openai) ]; };
}
