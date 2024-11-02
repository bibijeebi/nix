# overlays/moreutils.nix
{ lib, channels, ... }:

final: prev: {
  moreutilsPackages = let
    inherit (final) lib moreutils runCommand;

    binaries = [
      "chronic"
      "combine"
      "errno"
      "ifdata"
      "ifne"
      "isutf8"
      "lckdo"
      "mispipe"
      "parallel"
      "pee"
      "sponge"
      "ts"
      "vidir"
      "vipe"
      "zrun"
    ];

    # Function to create an individual package
    mkMoreUtilsPackage = name:
      runCommand name {
        inherit (moreutils) version meta;
        passthru = { inherit moreutils; };
      } ''
        mkdir -p $out/bin $out/share/man/man1
        ln -s ${moreutils}/bin/${name} $out/bin/${name}
        if [ -f ${moreutils}/share/man/man1/${name}.1.gz ]; then
          ln -s ${moreutils}/share/man/man1/${name}.1.gz $out/share/man/man1/${name}.1.gz
        fi
      '';

    # Function to create the package set
    mkMoreUtilsPackages = moreutils:
      let packages = lib.genAttrs binaries (name: mkMoreUtilsPackage name);
      in packages // {
        # Include the complete moreutils package
        full = moreutils;

        # Support for overriding the package set
        override = args: mkMoreUtilsPackages (moreutils.override args);
        overrideDerivation = f:
          mkMoreUtilsPackages (moreutils.overrideDerivation f);
      };
  in lib.recurseIntoAttrs (mkMoreUtilsPackages moreutils);
}
