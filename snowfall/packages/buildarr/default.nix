{pkgs, ...}: let
  buildarr = pkgs.callPackage ./buildarr.nix {};
  buildarr-radarr = pkgs.callPackage ./buildarr-radarr.nix {};
  buildarr-jellyseerr = pkgs.callPackage ./buildarr-jellyseerr.nix {};
  buildarr-prowlarr = pkgs.callPackage ./buildarr-prowlarr.nix {};
  buildarr-sonarr = pkgs.callPackage ./buildarr-sonarr.nix {};
in
  pkgs.python3.withPackages (ps: [
    buildarr
    buildarr-radarr
    buildarr-jellyseerr
    buildarr-prowlarr
    buildarr-sonarr
  ])
