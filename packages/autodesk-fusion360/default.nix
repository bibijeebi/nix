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

  dontUnpack = true;

  # Initialize wine prefix before installing
  preWineInit = ''
    # Ensure clean prefix
    rm -rf "$WINEPREFIX"
    mkdir -p "$WINEPREFIX"
  '';

  # Main installation steps
  winAppInstall = ''
    # Initialize wine prefix with required Windows version
    ${wine64}/bin/wineboot --init

    # Wait for wineboot
    while pgrep wineboot >/dev/null; do
      echo "Waiting for wineboot..."
      sleep 1
    done

    # Create required directories
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/Downloads"
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/AppData/Local/Autodesk/Neutron Platform/Options"
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/AppData/Roaming/Autodesk/Neutron Platform/Options"

    # Basic Windows requirements
    ${winetricks}/bin/winetricks -q atmlib gdiplus arial corefonts dotnet452
    ${winetricks}/bin/winetricks -q msxml4 msxml6 vcrun2017
    ${winetricks}/bin/winetricks -q fontsmooth=rgb winhttp win10

    # Copy installers
    cp ${src} "$WINEPREFIX/drive_c/users/$USER/Downloads/Fusion360installer.exe"
    cp ${webview2Installer} "$WINEPREFIX/drive_c/users/$USER/Downloads/WebView2installer.exe"

    # Install WebView2 first
    ${wine64}/bin/wine64 "$WINEPREFIX/drive_c/users/$USER/Downloads/WebView2installer.exe" /install

    # Install Fusion 360
    ${wine64}/bin/wine64 "$WINEPREFIX/drive_c/users/$USER/Downloads/Fusion360installer.exe" --quiet

    # Registry modifications for better compatibility
    ${wine64}/bin/wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "adpclientservice.exe" /t REG_SZ /d "" /f
    ${wine64}/bin/wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "AdCefWebBrowser.exe" /t REG_SZ /d "builtin" /f
    ${wine64}/bin/wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "msvcp140" /t REG_SZ /d "native" /f
    ${wine64}/bin/wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "mfc140u" /t REG_SZ /d "native" /f
    ${wine64}/bin/wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "bcp47langs" /t REG_SZ /d "" /f
  '';

  # File mappings for configuration persistence
  fileMap = {
    "$HOME/.config/fusion360/SumatraPDF-settings.txt" = "drive_c/fusion360/SumatraPDF-settings.txt";
    "$HOME/.cache/fusion360" = "drive_c/fusion360/cache";
    "$HOME/.config/fusion360/config" = "drive_c/users/$USER/AppData/Roaming/Autodesk/Neutron Platform/Options";
    "$HOME/.config/fusion360/local-config" = "drive_c/users/$USER/AppData/Local/Autodesk/Neutron Platform/Options";
  };

  # Launch command
  winAppRun = ''
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

  meta = with lib; {
    description = "Integrated CAD, CAM, and PCB design software";
    homepage = "https://www.autodesk.com/products/fusion-360/";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [binaryNativeCode];
    platforms = ["x86_64-linux"];
    maintainers = with maintainers; [];
  };
}
