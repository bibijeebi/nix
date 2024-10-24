{channels, ...}: _final: prev: {
  inherit (channels.unstable) aichat bottles blender code-cursor uv;

  fishPlugins =
    prev.fishPlugins
    // {
      fish-you-should-use = channels.unstable.fishPlugins.fish-you-should-use;
    };
}
