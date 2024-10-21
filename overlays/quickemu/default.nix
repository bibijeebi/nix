{
  channels,
  inputs,
  lib,
  ...
}: final: prev: {
  quickemu = prev.quickemu.override {
    OVMF = prev.OVMFFull.override {
      secureBoot = true;
      tpmSupport = true;
      httpSupport = true;
    };
  };
}
