{inputs, ...}: _final: _prev: {
  inherit
    (inputs.erosanix.lib.x86_64-linux)
    mkWindowsApp
    mkWindowsAppNoCC
    copyDesktopIcons
    makeDesktopIcon
    ;
}
