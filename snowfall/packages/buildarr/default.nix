{
  lib,
  callPackage,
  python311,
  fetchPypi,
  ...
}: let
  python = python311;
in rec {
  prowlarr-py = callPackage ./prowlarr-py.nix {inherit lib python fetchPypi;};
  radarr-py = callPackage ./radarr-py.nix {inherit lib python fetchPypi;};
  buildarr = callPackage ./buildarr.nix {inherit lib python fetchPypi;};
  buildarr-radarr = callPackage ./buildarr-radarr.nix {inherit lib python fetchPypi buildarr radarr-py;};
  buildarr-sonarr = callPackage ./buildarr-sonarr.nix {inherit lib python fetchPypi buildarr;};
  buildarr-prowlarr = callPackage ./buildarr-prowlarr.nix {inherit lib python fetchPypi buildarr prowlarr-py buildarr-radarr buildarr-sonarr;};
  buildarr-jellyseerr = callPackage ./buildarr-jellyseerr.nix {inherit lib python fetchPypi buildarr buildarr-radarr buildarr-sonarr;};
  default = buildarr;
}
