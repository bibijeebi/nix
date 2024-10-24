{
  lib,
  mkWindowsApp,
  wineWowPackages,
  fetchurl,
  makeDesktopItem,
  makeDesktopIcon,
  copyDesktopItems,
  copyDesktopIcons,
  winetricks,
  cabextract,
  gdk-pixbuf,
  libnotify,
  writeShellScript,
  makeWrapper,
  coreutils,
}: let
  winePackage = wineWowPackages.stable;

  # Create a launcher script that ensures directories exist
  launcherScript = writeShellScript "fusion360-launcher" ''
    # Ensure HOME is set
    export HOME=~

    # Create required directories
    mkdir -p "$HOME/.local/share/fusion360/prefix"

    # Set Wine environment
    export WINEARCH=win64
    export WINEPREFIX="$HOME/.local/share/fusion360/prefix"
    export WINEDLLOVERRIDES="winemenubuilder.exe=d;mscoree=d"
    export DXVK_LOG_LEVEL=none
    export DXVK_HUD=0

    # Initialize prefix if needed
    if [ ! -f "$WINEPREFIX/system.reg" ]; then
      echo "Initializing Wine prefix..."
      ${winePackage}/bin/wineboot --init

      # Wait for wineboot
      while pgrep wineboot >/dev/null; do
        sleep 1
      done
    fi

    # Find and launch Fusion 360
    FUSION_EXE=$(find "$WINEPREFIX/drive_c/Program Files/Autodesk/webdeploy/production/" -name "*.exe" -type f 2>/dev/null | head -1)
    if [ -n "$FUSION_EXE" ]; then
      exec ${winePackage}/bin/wine64 "$FUSION_EXE" "$@"
    else
      echo "Error: Fusion 360 executable not found. Running installer..."
      ${winePackage}/bin/wine64 "$WINEPREFIX/drive_c/users/$USER/Downloads/Fusion360installer.exe" --quiet
    fi
  '';
in
  mkWindowsApp rec {
    pname = "fusion360";
    version = "latest";

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
      winePackage
      makeWrapper
      coreutils
    ];

    buildInputs = [
      gdk-pixbuf
      libnotify
    ];

    wine = winePackage;
    wineArch = "win64";

    dontUnpack = true;

    winAppInstall = ''
      # Ensure directories exist
      mkdir -p "$WINEPREFIX"
      mkdir -p "$WINEPREFIX/drive_c/users/$USER/Downloads"
      mkdir -p "$WINEPREFIX/drive_c/users/$USER/AppData/Local/Autodesk/Neutron Platform/Options"
      mkdir -p "$WINEPREFIX/drive_c/users/$USER/AppData/Roaming/Autodesk/Neutron Platform/Options"

      # Initialize prefix
      ${winePackage}/bin/wineboot --init

      # Wait for wineboot
      while pgrep wineboot >/dev/null; do
        sleep 1
      done

      # Basic Windows requirements
      ${winetricks}/bin/winetricks -q dotnet452
      ${winetricks}/bin/winetricks -q win10
      ${winetricks}/bin/winetricks -q msxml4 msxml6
      ${winetricks}/bin/winetricks -q vcrun2017
      ${winetricks}/bin/winetricks -q atmlib gdiplus

      # Copy and install WebView2
      cp ${webview2Installer} "$WINEPREFIX/drive_c/users/$USER/Downloads/WebView2installer.exe"
      ${winePackage}/bin/wine64 "$WINEPREFIX/drive_c/users/$USER/Downloads/WebView2installer.exe" /silent /install

      # Copy and install Fusion 360
      cp ${src} "$WINEPREFIX/drive_c/users/$USER/Downloads/Fusion360installer.exe"
      ${winePackage}/bin/wine64 "$WINEPREFIX/drive_c/users/$USER/Downloads/Fusion360installer.exe" --quiet

      # Configure DLL overrides
      ${winePackage}/bin/wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "adpclientservice.exe" /t REG_SZ /d "" /f
      ${winePackage}/bin/wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "AdCefWebBrowser.exe" /t REG_SZ /d "builtin" /f
      ${winePackage}/bin/wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "msvcp140" /t REG_SZ /d "native" /f
      ${winePackage}/bin/wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "mfc140u" /t REG_SZ /d "native" /f
      ${winePackage}/bin/wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "bcp47langs" /t REG_SZ /d "" /f
    '';

    winAppRun = ''
      exec "${launcherScript}" "$@"
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      mkdir -p $out/share/applications

      # Install launcher script
      install -Dm755 ${launcherScript} $out/bin/${pname}

      # Copy desktop files and icons
      copyDesktopItems
      copyDesktopIcons

      runHook postInstall
    '';

    fileMap = {
      "$HOME/.config/fusion360/SumatraPDF-settings.txt" = "drive_c/fusion360/SumatraPDF-settings.txt";
      "$HOME/.cache/fusion360" = "drive_c/fusion360/cache";
      "$HOME/.config/fusion360/config" = "drive_c/users/$USER/AppData/Roaming/Autodesk/Neutron Platform/Options";
      "$HOME/.config/fusion360/local-config" = "drive_c/users/$USER/AppData/Local/Autodesk/Neutron Platform/Options";
    };

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
      platforms = ["x86_64-linux"];
    };
  }
