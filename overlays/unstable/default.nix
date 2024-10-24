{channels, ...}: _final: prev: {
  inherit (channels.unstable) aichat blender code-cursor uv;

  fishPlugins =
    prev.fishPlugins
    // {
      fish-you-should-use = channels.unstable.fishPlugins.fish-you-should-use;
    };
}
