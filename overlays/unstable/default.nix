{channels, ...}: final: prev: {
  inherit
    (channels.unstable)
    aichat
    blender
    code-cursor
    neovim
    super-slicer
    uv
    ;
}
