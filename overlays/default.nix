{inputs, lib, pkgs, ...}:
let 
  inherit (inputs) ante yazi;
in {
  nixpkgs.overlays = [
    ante.overlays.default
    yazi.overlays.default
  ];
}
