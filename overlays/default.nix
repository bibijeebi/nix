{ inputs, ... }:
let inherit (inputs) ante yazi;
in {
  nixpkgs.overlays = [
    ante.overlays.default
    yazi.overlays.default
    (import ./qimgv)
    (import ./vscode)
    (import ./quickemu)
    (import ./python-packages)
  ];
}
