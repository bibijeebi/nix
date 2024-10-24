{
  lib,
  mkWindowsApp,
  wine64,
  wine,
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
}:
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
    wine
    makeWrapper
  ];

  buildInputs = [
    gdk-pixbuf
    libnotify
  ];

  wine = wine64;
  wineArch = "win64";

  dontUnpack = true;

  # Create launcher script with proper environment setup
  launcher = writeShellScript "fusion360-launcher" ''
    export WINEARCH=win64
    export WINEPREFIX="$HOME/.local/share/fusion360/prefix"
    export WINEDLLOVERRIDES="winemenubuilder.exe=d;mscoree=d"
    export DXVK_LOG_LEVEL=none
    export DXVK_HUD=0

    # Create WINEPREFIX if it doesn't exist
    if [ ! -d "$WINEPREFIX" ]; then
      echo "Creating new Wine prefix..."

      # Initialize prefix
      ${wine64}/bin/wineboot --init

      # Wait for wineboot to finish
      while pgrep wineboot >/dev/null; do
        sleep 1
      done

      # Install basic requirements
      ${winetricks}/bin/winetricks -q dotnet452
      ${winetricks}/bin/winetricks -q win10
      ${winetricks}/bin/winetricks -q msxml4 msxml6
      ${winetricks}/bin/winetricks -q vcrun2017
      ${winetricks}/bin/winetricks -q atmlib gdiplus

      # Copy installers
      mkdir -p "$WINEPREFIX/drive_c/users/$USER/Downloads"
      cp ${webview2Installer} "$WINEPREFIX/drive_c/users/$USER/Downloads/WebView2installer.exe"
      cp ${src} "$WINEPREFIX/drive_c/users/$USER/Downloads/Fusion360installer.exe"

      # Install WebView2
      ${wine64}/bin/wine64 "$WINEPREFIX/drive_c/users/$USER/Downloads/WebView2installer.exe" /silent /install

      # Install Fusion 360
      cd "$WINEPREFIX/drive_c/users/$USER/Downloads"
      ${wine64}/bin/wine64 Fusion360installer.exe --quiet

      # Configure DLL overrides
      ${wine64}/bin/wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "adpclientservice.exe" /t REG_SZ /d "" /f
      ${wine64}/bin/wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "AdCefWebBrowser.exe" /t REG_SZ /d "builtin" /f
      ${wine64}/bin/wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "msvcp140" /t REG_SZ /d "native" /f
      ${wine64}/bin/wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "mfc140u" /t REG_SZ /d "native" /f
      ${wine64}/bin/wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "bcp47langs" /t REG_SZ /d "" /f
    fi

    # Find and launch Fusion 360
    FUSION_EXE=$(find "$WINEPREFIX/drive_c/Program Files/Autodesk/webdeploy/production/" -name "*.exe" -type f | head -1)
    if [ -n "$FUSION_EXE" ]; then
      exec ${wine64}/bin/wine64 "$FUSION_EXE" "$@"
    else
      echo "Error: Fusion 360 executable not found"
      exit 1
    fi
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/applications

    # Install launcher
    install -Dm755 ${launcher} $out/bin/${pname}

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
