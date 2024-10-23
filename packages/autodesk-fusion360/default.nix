{
  lib,
  mkWindowsApp,
  fetchurl,
  makeDesktopItem,
  makeDesktopIcon,
  copyDesktopItems,
  copyDesktopIcons,
  wine,
  winetricks,
  p7zip,
}: let
  version = "2.0.18313";

  # URLs for downloads
  fusion360Url = "https://dl.appstreaming.autodesk.com/production/installers/Fusion%20Admin%20Install.exe";
  webview2Url = "https://github.com/aedancullen/webview2-evergreen-standalone-installer-archive/releases/download/109.0.1518.78/MicrosoftEdgeWebView2RuntimeInstallerX64.exe";
  qt6WebEngineCoreUrl = "https://raw.githubusercontent.com/cryinkfly/Autodesk-Fusion-360-for-Linux/main/files/extras/patched-dlls/Qt6WebEngineCore.dll.7z";
  siappdllUrl = "https://raw.githubusercontent.com/cryinkfly/Autodesk-Fusion-360-for-Linux/main/files/extras/patched-dlls/siappdll.dll";
in
  mkWindowsApp rec {
    inherit version wine;

    pname = "fusion360";

    src = fetchurl {
      url = fusion360Url;
      sha256 = "sha256-hizfizCbmo9Hk1qEM26c13amdXLNcKD4QzdpQZcLnOE=";
    };

    webview2 = fetchurl {
      url = webview2Url;
      sha256 = "0nzxp64qfn9yii1n7cywl8ym88kzli2ak7sdcva045127s34kk7j";
    };

    qt6WebEngineCore = fetchurl {
      url = qt6WebEngineCoreUrl;
      sha256 = "1cll0g2vqsxasw7rhq0wxsb8qici4a29iaczdxahj5arlrlpjm62";
    };

    siappdll = fetchurl {
      url = siappdllUrl;
      sha256 = "1wy044ar27kyd7vq01axq0izw6hbkgjqacjgkshikxa3c5j6vs5a";
    };

    # We want notifications since Fusion install takes a while
    enableInstallNotification = true;

    # We need registry persistence for Fusion's settings
    persistRegistry = true;

    # Keep runtime layer for updates
    persistRuntimeLayer = true;

    inputHashMethod = "store-path";

    nativeBuildInputs = [copyDesktopItems copyDesktopIcons winetricks p7zip];

    dontUnpack = true;

    # Map config files to persist between runs
    fileMap = {
      "$HOME/.config/fusion360/Options" = "drive_c/users/$USER/AppData/Roaming/Autodesk/Neutron Platform/Options";
    };

    # Install required Windows components and Fusion 360
    winAppInstall = ''
      # Set up wine prefix with required components
      winetricks -q sandbox
      winetricks -q atmlib gdiplus arial corefonts cjkfonts dotnet452 msxml4 msxml6 vcrun2017 fontsmooth=rgb winhttp win10

      # Install WebView2
      cp ${webview2} "$WINEPREFIX/drive_c/webview2.exe"
      $WINE "$WINEPREFIX/drive_c/webview2.exe" /silent /install
      wineserver -w

      # Install Fusion 360
      $WINE ${src} --quiet
      wineserver -w

      # Extract and install patched DLLs
      mkdir -p "$WINEPREFIX/drive_c/Program Files/Autodesk/webEngine"
      7z e ${qt6WebEngineCore} -o"$WINEPREFIX/drive_c/Program Files/Autodesk/webEngine"
      cp ${siappdll} "$WINEPREFIX/drive_c/Program Files/Autodesk/webEngine"

      # Configure registry
      $WINE reg ADD "HKCU\\Software\\Wine\\DllOverrides" /v "adpclientservice.exe" /t REG_SZ /d "" /f
      $WINE reg ADD "HKCU\\Software\\Wine\\DllOverrides" /v "AdCefWebBrowser.exe" /t REG_SZ /d builtin /f
      $WINE reg ADD "HKCU\\Software\\Wine\\DllOverrides" /v "msvcp140" /t REG_SZ /d native /f
      $WINE reg ADD "HKCU\\Software\\Wine\\DllOverrides" /v "mfc140u" /t REG_SZ /d native /f
      $WINE reg ADD "HKCU\\Software\\Wine\\DllOverrides" /v "bcp47langs" /t REG_SZ /d "" /f
    '';

    # Launch Fusion 360
    winAppRun = ''
      $WINE "$WINEPREFIX/drive_c/Program Files/Autodesk/Fusion 360/Fusion360.exe" "$ARGS"
    '';

    installPhase = ''
      runHook preInstall
      ln -s $out/bin/.launcher $out/bin/${pname}
      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "Fusion360";
        exec = pname;
        icon = pname;
        desktopName = "Autodesk Fusion 360";
        genericName = "CAD Application";
        categories = ["Graphics" "Engineering"];
        mimeTypes = ["x-scheme-handler/fusion360"];
      })
    ];

    desktopIcon = makeDesktopIcon {
      name = pname;
      src = fetchurl {
        url = "https://raw.githubusercontent.com/cryinkfly/Autodesk-Fusion-360-for-Linux/main/files/setup/resource/graphics/autodesk_fusion.svg";
        sha256 = "sha256-YSz+4mWksZbut/gv4dt7d6MjsKhqNgWU2rbO2KmixOw=";
      };
    };

    meta = with lib; {
      description = "Cloud-based 3D CAD/CAM software for product design and manufacturing";
      homepage = "https://www.autodesk.com/products/fusion-360/";
      license = licenses.unfree;
      maintainers = with maintainers; [];
      platforms = ["x86_64-linux"];
    };
  }
