{
  lib,
  callPackage,
  python311,
  fetchPypi,
  ...
}: let
  python = python311;

  pydantic = callPackage ./pydantic.nix {inherit lib python fetchPypi;};
  prowlarr-py = callPackage ./prowlarr-py.nix {inherit lib python fetchPypi pydantic;};
  radarr-py = callPackage ./radarr-py.nix {inherit lib python fetchPypi;};
  buildarr = callPackage ./buildarr.nix {inherit lib python fetchPypi;};
  buildarr-radarr = callPackage ./buildarr-radarr.nix {inherit lib python fetchPypi buildarr radarr-py;};
  buildarr-sonarr = callPackage ./buildarr-sonarr.nix {inherit lib python fetchPypi buildarr;};
  buildarr-prowlarr = callPackage ./buildarr-prowlarr.nix {inherit lib python fetchPypi buildarr prowlarr-py buildarr-radarr buildarr-sonarr;};
  buildarr-jellyseerr = callPackage ./buildarr-jellyseerr.nix {inherit lib python fetchPypi buildarr buildarr-radarr buildarr-sonarr pydantic;};
in
  buildarr.overridePythonAttrs (oldAttrs: {
    propagatedBuildInputs =
      (oldAttrs.propagatedBuildInputs or [])
      ++ [
        buildarr-radarr
        buildarr-sonarr
        buildarr-prowlarr
        buildarr-jellyseerr
      ];
  })
