final: prev: {
  pythonPackagesOverlays =
    (prev.pythonPackagesOverlays or [])
    ++ [
      (python-final: python-prev: {
        buildarr = python-prev.callPackage ./buildarr.nix {};
        buildarr-radarr = python-prev.callPackage ./buildarr-radarr.nix {};
        buildarr-sonarr = python-prev.callPackage ./buildarr-sonarr.nix {};
        buildarr-prowlarr = python-prev.callPackage ./buildarr-prowlarr.nix {};
        buildarr-jellyseerr = python-prev.callPackage ./buildarr-jellyseerr.nix {};
      })
    ];
}
