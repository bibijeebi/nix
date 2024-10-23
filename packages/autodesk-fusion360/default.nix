{
  fetchurl,
  imagemagick,
  inputs,
  lib,
  p7zip,
  stdenv,
  wine,
  winetricks,
, copyDesktopIcons
, copyDesktopItems
, makeDesktopIcon
, makeDesktopItem
}: let
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
    inherit wine;

    pname = "autodesk-fusion360";
    version = "latest";

    src = fetchurl {
      url = "https://dl.appstreaming.autodesk.com/production/installers/Fusion%20Admin%20Install.exe";
      sha256 = "sha256-hizfizCbmo9Hk1qEM26c13amdXLNcKD4QzdpQZcLnOE=";
    };

    src = fetchurl {
      url = "https://raw.githubusercontent.com/cryinkfly/Autodesk-Fusion-360-for-Linux/main/files/setup/data/autodesk_fusion_launcher.sh";
      sha256 = "";
s    }

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
    enableInstallNotification = true;
    persistRegistry = true;

    nativeBuildInputs = [
      p7zip
      copyDesktopItems
    ];

    winAppInstall = ''
      winetricks sandbox
      winetricks atmlib gdiplus arial corefonts cjkfonts dotnet452 msxml4 msxml6 vcrun2017 fontsmooth=rgb winhttp win10
      winetricks cjkfonts
      winetricks win11

      $WINE ${src} /silent /install
      $WINE ${webview2} /silent /install
      $WINE ${qt6webenginecore} /silent /install
      $WINE ${siappdll} /silent /install

      wine REG ADD "HKCU\Software\Wine\DllOverrides" /v "adpclientservice.exe" /t REG_SZ /d "" /f
      wine REG ADD "HKCU\Software\Wine\DllOverrides" /v "AdCefWebBrowser.exe" /t REG_SZ /d builtin /f
      wine REG ADD "HKCU\Software\Wine\DllOverrides" /v "msvcp140" /t REG_SZ /d native /f
      wine REG ADD "HKCU\Software\Wine\DllOverrides" /v "mfc140u" /t REG_SZ /d native /f
      wine reg add "HKCU\Software\Wine\DllOverrides" /v "bcp47langs" /t REG_SZ /d "" /f

      winetricks vd="$MONITOR_RESOLUTION"
    '';

    winAppRun = ''
      wine "$WINEPREFIX/drive_c/Program Files/Autodesk/Fusion 360/Fusion360.exe" "$ARGS"
    '';

    # File mapping for persistence
    fileMap = {
      "$HOME/.config/Autodesk/Fusion360" = "drive_c/users/$USER/Application Data/Autodesk/Fusion360";
      "$HOME/.local/share/fusion360" = "drive_c/users/$USER/Documents/Fusion360";
    };

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
