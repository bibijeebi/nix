{
  lib,
  mkWindowsApp,
  wineWowPackages,
  fetchurl,
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
  # Use stagingFull which includes winbind and other dependencies
  winePackage = wineWowPackages.stagingFull;

  launcherScript = writeShellScript "fusion360-launcher" ''
    # Ensure proper home directory setup
    if [ -z "$HOME" ]; then
      export HOME=~
    fi

    # Create required directories
    WINE_BASE_DIR="$HOME/.local/share/fusion360"
    WINEPREFIX="$WINE_BASE_DIR/prefix"
    mkdir -p "$WINEPREFIX"
    mkdir -p "$WINE_BASE_DIR/cache"
    mkdir -p "$WINE_BASE_DIR/config"

    # Set Wine environment
    export WINEARCH=win64
    export WINEDEBUG=-all
    export WINEPREFIX="$WINEPREFIX"
    export WINEDLLOVERRIDES="winemenubuilder.exe=d;mscoree=d"
    export NIX_STORE_DIR="$HOME/nix/store"
    export NIX_STATE_DIR="$HOME/nix/var/nix"
    export NIX_LOG_DIR="$HOME/nix/var/log/nix"

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

    preWineInit = ''
      # Ensure HOME is set properly
      if [ -z "$HOME" ]; then
        export HOME=~
      fi

      # Create required directories
      WINE_BASE_DIR="$HOME/.local/share/fusion360"
      export WINEPREFIX="$WINE_BASE_DIR/prefix"
      mkdir -p "$WINEPREFIX"
    '';

    winAppInstall = ''
      # Ensure proper environment
      export HOME=~
      export NIX_STORE_DIR="$HOME/nix/store"
      export NIX_STATE_DIR="$HOME/nix/var/nix"
      export NIX_LOG_DIR="$HOME/nix/var/log/nix"

      # Basic Windows requirements
      ${winetricks}/bin/winetricks -q dotnet452 corefonts
      ${winetricks}/bin/winetricks -q win10
      ${winetricks}/bin/winetricks -q msxml4 msxml6
      ${winetricks}/bin/winetricks -q vcrun2017
      ${winetricks}/bin/winetricks -q winhttp
      ${winetricks}/bin/winetricks -q atmlib
      ${winetricks}/bin/winetricks -q gdiplus

      # Configure Wine
      ${winePackage}/bin/wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "winemenubuilder.exe" /t REG_SZ /d "" /f
      ${winePackage}/bin/wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "mscoree" /t REG_SZ /d "" /f
      ${winePackage}/bin/wine reg add "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Windows" /v "LoadAppInit_DLLs" /t REG_DWORD /d 0 /f
      ${winePackage}/bin/wine reg add "HKLM\\Software\\Policies\\Microsoft\\Windows\\System" /v "EnableSmartScreen" /t REG_DWORD /d 0 /f
      ${winePackage}/bin/wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "wintrust" /t REG_SZ /d "native,builtin" /f
      ${winePackage}/bin/wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "crypt32" /t REG_SZ /d "native,builtin" /f

      # Install WebView2
      cp ${webview2Installer} "$WINEPREFIX/drive_c/users/$USER/Downloads/WebView2installer.exe"
      ${winePackage}/bin/wine64 "$WINEPREFIX/drive_c/users/$USER/Downloads/WebView2installer.exe" /silent /install

      # Install Fusion 360
      cp ${src} "$WINEPREFIX/drive_c/users/$USER/Downloads/Fusion360installer.exe"
      ${winePackage}/bin/wine64 "$WINEPREFIX/drive_c/users/$USER/Downloads/Fusion360installer.exe" --quiet
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

    meta = with lib; {
      description = "Integrated CAD, CAM, and PCB design software";
      homepage = "https://www.autodesk.com/products/fusion-360/";
      license = licenses.unfree;
      platforms = ["x86_64-linux"];
    };
  }
