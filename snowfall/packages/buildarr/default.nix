{
  lib,
  callPackage,
  python311,
  fetchPypi,
  ...
}: let
  python = python311;

  prowlarr-py = callPackage ./prowlarr-py.nix {inherit lib python fetchPypi;};
  radarr-py = callPackage ./radarr-py.nix {inherit lib python fetchPypi;};
  buildarr-radarr = callPackage ./buildarr-radarr.nix {inherit lib python fetchPypi radarr-py;};
  buildarr-sonarr = callPackage ./buildarr-sonarr.nix {inherit lib python fetchPypi;};
  buildarr-prowlarr = callPackage ./buildarr-prowlarr.nix {inherit lib python fetchPypi prowlarr-py buildarr-radarr buildarr-sonarr;};
  buildarr-jellyseerr = callPackage ./buildarr-jellyseerr.nix {inherit lib python fetchPypi buildarr-radarr buildarr-sonarr;};

  buildarr = let
    pythonWithPackages = python.withPackages (ps: [
      buildarr-radarr
      buildarr-sonarr
      buildarr-prowlarr
      buildarr-jellyseerr
    ]);
  in
    callPackage ./buildarr.nix {
      inherit lib fetchPypi;
      python = pythonWithPackages;
    };
in
  buildarr
