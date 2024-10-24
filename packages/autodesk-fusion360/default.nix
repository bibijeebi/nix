{
  lib,
  mkWindowsApp,
  wine64, # Explicitly use wine64
  wine, # Need this for winetricks
  fetchurl,
  makeDesktopItem,
  makeDesktopIcon,
  copyDesktopItems,
  copyDesktopIcons,
  winetricks,
  cabextract,
  gdk-pixbuf,
  libnotify,
}:
mkWindowsApp rec {
  pname = "fusion360";
  version = "latest"; # Fusion 360 uses rolling releases

  # The installer is downloaded dynamically by the script, we'll need to fetch it
  src = fetchurl {
    url = "https://dl.appstreaming.autodesk.com/production/installers/Fusion%20Admin%20Install.exe";
    sha256 = "sha256:1qcw1fbl2s9p8gwa0w6df9sscxnpkip3712sjd3qz6lv625xyb46";
  };

  webview2Installer = fetchurl {
    url = "https://github.com/aedancullen/webview2-evergreen-standalone-installer-archive/releases/download/109.0.1518.78/MicrosoftEdgeWebView2RuntimeInstallerX64.exe";
    sha256 = "sha256-8sxJhj4iFALUZk2fqUSkfyJUPaLcs2NDjD5Zh4m5/Vs=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    copyDesktopIcons
    winetricks
    cabextract
    wine # Needed for winetricks
  ];

  buildInputs = [
    gdk-pixbuf
    libnotify
  ];

  # Use wine64 explicitly
  wine = wine64;
  wineArch = "win64";

  # DLL overrides in winetricks format
  dllOverrides = "adpclientservice=disabled;AdCefWebBrowser.exe=builtin;msvcp140=native;mfc140u=native;bcp47langs=disabled";

  # Based on the required packages from the install script
  winAppInstall = ''
    # Initialize fresh 64-bit prefix
    rm -rf "$WINEPREFIX"
    mkdir -p "$WINEPREFIX"

    # Ensure we're using 64-bit wine
    export WINEARCH=win64
    export WINEPREFIX="$WINEPREFIX"

    # Initialize wine prefix
    ${wine64}/bin/wineboot --init

    # Wait for wineboot to finish
    while pgrep wineboot >/dev/null; do
      echo "Waiting for wineboot to finish..."
      sleep 1
    done

    # Create all required directories
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/Downloads"
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/AppData/Roaming/Microsoft/Internet Explorer/Quick Launch/User Pinned/"
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/AppData/Roaming/Autodesk/Neutron Platform/Options"
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/AppData/Local/Autodesk/Neutron Platform/Options"
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/Application Data/Autodesk/Neutron Platform/Options"

    # Setup winetricks requirements
    ${winetricks}/bin/winetricks -q atmlib gdiplus arial corefonts cjkfonts
    ${winetricks}/bin/winetricks -q dotnet452 msxml4 msxml6 vcrun2017
    ${winetricks}/bin/winetricks -q fontsmooth=rgb winhttp win10

    # Run cjkfonts again as sometimes it fails first time
    ${winetricks}/bin/winetricks -q cjkfonts

    # Copy installers to wine prefix
    cp ${src} "$WINEPREFIX/drive_c/users/$USER/Downloads/Fusion360installer.exe"
    cp ${webview2Installer} "$WINEPREFIX/drive_c/users/$USER/Downloads/WebView2installer.exe"

    # Install WebView2
    ${wine64}/bin/wine64 "$WINEPREFIX/drive_c/users/$USER/Downloads/WebView2installer.exe" /install

    # Install Fusion 360
    ${wine64}/bin/wine64 "$WINEPREFIX/drive_c/users/$USER/Downloads/Fusion360installer.exe" --quiet
  '';

  # Enable Vulkan/DXVK support
  enableVulkan = true;

  # File mappings for configuration persistence
  fileMap = {
    "$HOME/.config/fusion360/SumatraPDF-settings.txt" = "drive_c/fusion360/SumatraPDF-settings.txt";
    "$HOME/.cache/fusion360" = "drive_c/fusion360/cache";
    "$HOME/.config/fusion360/config" = "drive_c/users/$USER/AppData/Roaming/Autodesk/Neutron Platform/Options";
    "$HOME/.config/fusion360/local-config" = "drive_c/users/$USER/AppData/Local/Autodesk/Neutron Platform/Options";
  };

  # Run Fusion 360
  winAppRun = ''
    export WINEARCH=win64
    export WINEPREFIX="$WINEPREFIX"

    # Create required directories if they don't exist
    mkdir -p "$HOME/.config/fusion360"
    mkdir -p "$HOME/.cache/fusion360"

    ${wine64}/bin/wine64 "$WINEPREFIX/drive_c/Program Files/Autodesk/webdeploy/production/*.exe" "$ARGS"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "Autodesk Fusion 360";
      genericName = "CAD Application";
      categories = ["Graphics" "Engineering"];
      mimeTypes = ["x-scheme-handler/adskidmgr"];
    })
  ];

  # Convert the ICO file to PNG for the desktop icon
  desktopIcon = makeDesktopIcon {
    name = pname;
    src = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/cryinkfly/Autodesk-Fusion-360-for-Linux/refs/heads/main/files/builds/stable-branch/bin/Fusion360.ico";
      sha256 = "sha256:0ljgii5pf28y171dab23dghj8hslfimdigvvrwhnkj0rwkpz09is";
    };
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    ln -s $out/bin/.launcher $out/bin/${pname}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Integrated CAD, CAM, and PCB design software";
    homepage = "https://www.autodesk.com/products/fusion-360/";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [binaryNativeCode];
    platforms = ["x86_64-linux"];
    maintainers = with maintainers; [];
  };
}
