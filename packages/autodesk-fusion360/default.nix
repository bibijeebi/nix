{
  lib,
  mkWindowsApp,
  wine,
  fetchurl,
  makeDesktopItem,
  makeDesktopIcon,
  copyDesktopItems,
  copyDesktopIcons,
  winetricks,
  cabextract,
}:
mkWindowsApp rec {
  pname = "fusion360";
  version = "latest"; # Fusion 360 uses rolling releases

  # The installer is downloaded dynamically by the script, we'll need to fetch it
  src = fetchurl {
    url = "https://dl.appstreaming.autodesk.com/production/installers/Fusion%20Admin%20Install.exe";
    sha256 = ""; # Need to add actual hash
  };

  webview2Installer = fetchurl {
    url = "https://github.com/aedancullen/webview2-evergreen-standalone-installer-archive/releases/download/109.0.1518.78/MicrosoftEdgeWebView2RuntimeInstallerX64.exe";
    sha256 = ""; # Need to add actual hash
  };

  nativeBuildInputs = [
    copyDesktopItems
    copyDesktopIcons
    winetricks
    cabextract
  ];

  inherit wine;
  wineArch = "win64";

  # Required DLL overrides from the install script
  dllOverrides = {
    adpclientservice = ""; # Remove tracking metrics
    "AdCefWebBrowser.exe" = "builtin"; # Navigation bar fix
    msvcp140 = "native"; # Use bundled VS redist
    mfc140u = "native"; # Use bundled VS redist
    bcp47langs = ""; # Fix login issues
  };

  # Based on the required packages from the install script
  winetricksRequirements = [
    "atmlib"
    "gdiplus"
    "arial"
    "corefonts"
    "cjkfonts"
    "dotnet452"
    "msxml4"
    "msxml6"
    "vcrun2017"
    "fontsmooth=rgb"
    "winhttp"
    "win10"
  ];

  # Enable Vulkan/DXVK support as per the install script
  enableVulkan = true;

  # File mappings for configuration persistence
  fileMap = {
    "$HOME/.config/fusion360/SumatraPDF-settings.txt" = "drive_c/fusion360/SumatraPDF-settings.txt";
    "$HOME/.cache/fusion360" = "drive_c/fusion360/cache";
  };

  # Installation steps from the script
  winAppInstall = ''
    # Copy installers to wine prefix
    cp ${src} $WINEPREFIX/drive_c/users/$USER/Downloads/Fusion360installer.exe
    cp ${webview2Installer} $WINEPREFIX/drive_c/users/$USER/Downloads/WebView2installer.exe

    # Install WebView2
    wine $WINEPREFIX/drive_c/users/$USER/Downloads/WebView2installer.exe /install

    # Create required directories
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/AppData/Roaming/Microsoft/Internet Explorer/Quick Launch/User Pinned/"
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/AppData/Roaming/Autodesk/Neutron Platform/Options"
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/AppData/Local/Autodesk/Neutron Platform/Options"
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/Application Data/Autodesk/Neutron Platform/Options"

    # Install Fusion 360
    wine $WINEPREFIX/drive_c/users/$USER/Downloads/Fusion360installer.exe --quiet
  '';

  # Run Fusion 360
  winAppRun = ''
    wine "$WINEPREFIX/drive_c/Program Files/Autodesk/webdeploy/production/*.exe" "$ARGS"
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

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = fetchurl {
      url = "https://raw.githubusercontent.com/cryinkfly/Autodesk-Fusion-360-for-Linux/main/files/builds/stable-branch/bin/fusion360.svg";
      sha256 = ""; # Need to add actual hash
    };
  };

  meta = with lib; {
    description = "Integrated CAD, CAM, and PCB design software";
    homepage = "https://www.autodesk.com/products/fusion-360/";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [binaryNativeCode];
    platforms = ["x86_64-linux"];
    maintainers = with maintainers; [];
  };
}
