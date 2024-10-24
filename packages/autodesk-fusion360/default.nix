{
  lib,
  mkWindowsApp,
  wine64,
  fetchurl,
  makeDesktopItem,
  makeDesktopIcon,
  copyDesktopItems,
  copyDesktopIcons,
  winetricks,
  cabextract,
  bindfs,
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
  ];

  buildInputs = [
    bindfs
    gdk-pixbuf
    libnotify
  ];

  # Use wine64 explicitly
  wine = wine64;
  wineArch = "win64";

  # DLL overrides in winetricks format
  dllOverrides = "adpclientservice=disabled;AdCefWebBrowser.exe=builtin;msvcp140=native;mfc140u=native;bcp47langs=disabled";

  # Create necessary directories before wine initialization
  preWineInit = ''
    mkdir -p "$WINEPREFIX"
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/Downloads"
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/AppData/Roaming/Microsoft/Internet Explorer/Quick Launch/User Pinned/"
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/AppData/Roaming/Autodesk/Neutron Platform/Options"
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/AppData/Local/Autodesk/Neutron Platform/Options"
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/Application Data/Autodesk/Neutron Platform/Options"
  '';

  # Based on the required packages from the install script
  winAppInstall = ''
    # Make sure we're starting fresh
    rm -rf $WINEPREFIX/*

    # Initialize 64-bit prefix
    WINEARCH=win64 wineboot --init

    # Wait for wineboot to finish
    while pgrep wineboot >/dev/null; do
      echo "Waiting for wineboot to finish..."
      sleep 1
    done

    # Setup winetricks requirements
    WINEARCH=win64 winetricks -q atmlib gdiplus arial corefonts cjkfonts dotnet452 msxml4 msxml6 vcrun2017
    WINEARCH=win64 winetricks -q fontsmooth=rgb winhttp win10

    # Run cjkfonts again as sometimes it fails first time
    WINEARCH=win64 winetricks -q cjkfonts

    # Ensure Windows 10 mode is set
    WINEARCH=win64 winetricks -q win10

    # Copy installers to wine prefix
    cp ${src} "$WINEPREFIX/drive_c/users/$USER/Downloads/Fusion360installer.exe"
    cp ${webview2Installer} "$WINEPREFIX/drive_c/users/$USER/Downloads/WebView2installer.exe"

    # Install WebView2
    WINEARCH=win64 wine "$WINEPREFIX/drive_c/users/$USER/Downloads/WebView2installer.exe" /install

    # Wait for WebView2 installation to finish
    while pgrep WebView2 >/dev/null; do
      echo "Waiting for WebView2 installation to finish..."
      sleep 1
    done

    # Install Fusion 360
    WINEARCH=win64 wine "$WINEPREFIX/drive_c/users/$USER/Downloads/Fusion360installer.exe" --quiet
  '';

  # Enable Vulkan/DXVK support as per the install script
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
    # Create required directories if they don't exist
    mkdir -p "$HOME/.config/fusion360"
    mkdir -p "$HOME/.cache/fusion360"

    # Mount directories using bindfs instead of fusermount
    for dir in "$HOME/.config/fusion360" "$HOME/.cache/fusion360"; do
      if ! mountpoint -q "$dir"; then
        bindfs --no-allow-other "$dir" "$dir"
      fi
    done

    WINEARCH=win64 wine "$WINEPREFIX/drive_c/Program Files/Autodesk/webdeploy/production/*.exe" "$ARGS"
  '';

  # Clean up bindfs mounts
  postRun = ''
    for dir in "$HOME/.config/fusion360" "$HOME/.cache/fusion360"; do
      if mountpoint -q "$dir"; then
        umount "$dir"
      fi
    done
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

  # Skip the unpack phase since we're using the exe directly
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
