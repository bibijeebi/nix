{...}: final: prev: {
  inherit
    (prev.internal)
    buildarr
    buildarr-radarr
    buildarr-sonarr
    buildarr-prowlarr
    buildarr-jellyseerr
    ;
}
