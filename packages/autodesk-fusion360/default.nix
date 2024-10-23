{
  lib,
  inputs,
  fetchurl,
  wine64, # Explicitly use wine64
  stdenv,
  makeDesktopItem,
  copyDesktopItems,
  imagemagick,
  p7zip,
  winetricks,
  fuse,
  gdk-pixbuf,
  notify-desktop,
}: let
  mkWindowsApp = inputs.erosanix.lib.x86_64-linux.mkWindowsApp;

  icons = stdenv.mkDerivation {
    name = "fusion360-icons";

    src = fetchurl {
      url = "https://raw.githubusercontent.com/cryinkfly/Autodesk-Fusion-360-for-Linux/main/files/setup/resource/graphics/autodesk_fusion.svg";
      sha256 = "sha256-YSz+4mWksZbut/gv4dt7d6MjsKhqNgWU2rbO2KmixOw=";
    };

    dontUnpack = true;
    nativeBuildInputs = [imagemagick];

    installPhase = ''
      for n in 16 24 32 48 64 96 128 256; do
        size=$n"x"$n
        mkdir -p $out/hicolor/$size/apps
        convert $src -resize $size $out/hicolor/$size/apps/fusion360.png
      done;
    '';
  };
in
  mkWindowsApp rec {
    inherit (wine64) wine; # Use wine64's wine

    pname = "autodesk-fusion360";
    version = "latest";

    src = fetchurl {
      url = "https://dl.appstreaming.autodesk.com/production/installers/Fusion%20Admin%20Install.exe";
      sha256 = "sha256-hizfizCbmo9Hk1qEM26c13amdXLNcKD4QzdpQZcLnOE=";
    };

    webview2 = fetchurl {
      url = "https://github.com/aedancullen/webview2-evergreen-standalone-installer-archive/releases/download/109.0.1518.78/MicrosoftEdgeWebView2RuntimeInstallerX64.exe";
      sha256 = "0nzxp64qfn9yii1n7cywl8ym88kzli2ak7sdcva045127s34kk7j";
    };

    qt6webenginecore = fetchurl {
      url = "https://raw.githubusercontent.com/cryinkfly/Autodesk-Fusion-360-for-Linux/main/files/extras/patched-dlls/Qt6WebEngineCore.dll.7z";
      sha256 = "1cll0g2vqsxasw7rhq0wxsb8qici4a29iaczdxahj5arlrlpjm62";
    };

    siappdll = fetchurl {
      url = "https://raw.githubusercontent.com/cryinkfly/Autodesk-Fusion-360-for-Linux/main/files/extras/patched-dlls/siappdll.dll";
      sha256 = "1wy044ar27kyd7vq01axq0izw6hbkgjqacjgkshikxa3c5j6vs5a";
    };

    dontUnpack = true;
    wineArch = "win64";

    nativeBuildInputs = [
      copyDesktopItems
      p7zip
      winetricks
      gdk-pixbuf
      notify-desktop
    ];

    buildInputs = [
      wine64
      fuse
    ];

    # Add runtime dependencies
    runtimeInputs = [
      wine64
      p7zip
      winetricks
      gdk-pixbuf
      fuse
    ];

    enableInstallNotification = true;

    # Initialize WINEPREFIX before installation
    winAppPreInstall = ''
      # Ensure clean WINEPREFIX
      rm -rf "$WINEPREFIX"
      # Initialize 64-bit prefix
      WINEARCH=win64 wineboot --init
      while pgrep wineboot >/dev/null; do
        sleep 1
      done
    '';

    winAppInstall = ''
      # Configure Wine
      winetricks -q atmlib gdiplus arial corefonts cjkfonts dotnet452 msxml4 msxml6 vcrun2017 fontsmooth=rgb winhttp win10

      # Configure registry
      wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "adpclientservice.exe" /t REG_SZ /d "" /f
      wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "AdCefWebBrowser.exe" /t REG_SZ /d "builtin" /f
      wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "msvcp140" /t REG_SZ /d "native" /f
      wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "mfc140u" /t REG_SZ /d "native" /f
      wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "bcp47langs" /t REG_SZ /d "" /f

      # Install WebView2
      wine ${webview2} /silent /install
      wineserver -w

      # Install Fusion 360
      wine ${src} --quiet
      wineserver -w

      # Create required directories
      mkdir -p "$WINEPREFIX/drive_c/Program Files/Autodesk/webengine/"
      mkdir -p "$WINEPREFIX/drive_c/Program Files/Autodesk/"

      # Extract and patch Qt6WebEngineCore.dll
      ${p7zip}/bin/7z x ${qt6webenginecore} -o"$WINEPREFIX/drive_c/Program Files/Autodesk/webengine/"

      # Copy siappdll
      cp ${siappdll} "$WINEPREFIX/drive_c/Program Files/Autodesk/"
    '';

    winAppRun = ''
      wine "C:/Program Files/Autodesk/Fusion 360/Fusion360.exe" "$ARGS"
    '';

    # File mapping for persistence
    fileMap = {
      "$HOME/.config/Autodesk/Fusion360" = "drive_c/users/$USER/Application Data/Autodesk/Fusion360";
      "$HOME/.local/share/fusion360" = "drive_c/users/$USER/Documents/Fusion360";
    };

    # Enable registry persistence
    persistRegistry = true;

    installPhase = ''
      runHook preInstall

      ln -s $out/bin/.launcher $out/bin/fusion360
      mkdir -p $out/share/icons
      ln -s ${icons}/hicolor $out/share/icons

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = pname;
        exec = "fusion360";
        icon = "fusion360";
        desktopName = "Autodesk Fusion 360";
        genericName = "CAD Application";
        categories = ["Graphics" "Engineering"];
      })
    ];

    meta = with lib; {
      description = "Cloud-based 3D CAD/CAM tool for product development";
      homepage = "https://www.autodesk.com/products/fusion-360";
      license = licenses.unfree;
      maintainers = with maintainers; [];
      mainProgram = "fusion360";
      platforms = ["x86_64-linux"];
    };
  }
