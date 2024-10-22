{channels, ...}: final: prev: {
  inherit
    (channels.unstable)
    aichat
    blender
    code-cursor
    uv
    ;
}
