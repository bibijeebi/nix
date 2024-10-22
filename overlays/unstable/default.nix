{channels, ...}: final: prev: {
  inherit
    (channels.unstable)
    aichat
    blender
    chromium
    code-cursor
    firefox
    google-chrome
    neovim
    super-slicer
    uv
    ;
}
