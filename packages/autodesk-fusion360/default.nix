{
  lib,
  mkWindowsApp,
  fetchurl,
  wine,
}:
mkWindowsApp rec {
  pname = "autodesk-fusion360";
  version = "latest"; # Version is managed by Autodesk's installer

  src = fetchurl {
    url = "https://dl.appstreaming.autodesk.com/production/installers/Fusion%20Admin%20Install.exe";
    sha256 = ""; # Add SHA256 after downloading
  };

  # Required DLLs/patches
  webview2 = fetchurl {
    url = "https://github.com/aedancullen/webview2-evergreen-standalone-installer-archive/releases/download/109.0.1518.78/MicrosoftEdgeWebView2RuntimeInstallerX64.exe";
    sha256 = ""; # Add SHA256 after downloading
  };

  qt6webenginecore = fetchurl {
    url = "https://raw.githubusercontent.com/cryinkfly/Autodesk-Fusion-360-for-Linux/main/files/extras/patched-dlls/Qt6WebEngineCore.dll.7z";
    sha256 = ""; # Add SHA256 after downloading
  };

  siappdll = fetchurl {
    url = "https://raw.githubusercontent.com/cryinkfly/Autodesk-Fusion-360-for-Linux/main/files/extras/patched-dlls/siappdll.dll";
    sha256 = ""; # Add SHA256 after downloading
  };

  inherit wine;

  # Required Windows dependencies
  wineFlags = [
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

  # Registry tweaks
  registryEntries = {
    "HKCU\\Software\\Wine\\DllOverrides" = {
      "adpclientservice.exe" = {
        type = "REG_SZ";
        value = "";
      };
      "AdCefWebBrowser.exe" = {
        type = "REG_SZ";
        value = "builtin";
      };
      "msvcp140" = {
        type = "REG_SZ";
        value = "native";
      };
      "mfc140u" = {
        type = "REG_SZ";
        value = "native";
      };
      "bcp47langs" = {
        type = "REG_SZ";
        value = "";
      };
    };
  };

  # Installation steps
  winAppInstall = ''
    # Install WebView2
    wine ${webview2} /silent /install

    # Install Fusion 360
    wine ${src} --quiet

    # Patch DLLs
    cp ${qt6webenginecore} "$WINEPREFIX/drive_c/Program Files/Autodesk/webengine/Qt6WebEngineCore.dll"
    cp ${siappdll} "$WINEPREFIX/drive_c/Program Files/Autodesk/siappdll.dll"
  '';

  # Runtime configuration
  winAppRun = ''
    # Configure environment
    export WINEPREFIX="$HOME/.autodesk_fusion"

    # Run Fusion 360
    wine "C:/Program Files/Autodesk/Fusion 360/Fusion360.exe"
  '';

  # Enable Vulkan/DXVK for better graphics performance
  enableVulkan = true;

  # Persist settings and config
  persistRegistry = true;
  fileMap = {
    "$HOME/.config/Autodesk/Fusion360" = "drive_c/users/$USER/Application Data/Autodesk/Fusion360";
  };

  meta = with lib; {
    description = "Cloud-based 3D CAD/CAM tool for product development";
    homepage = "https://www.autodesk.com/products/fusion-360";
    license = licenses.unfree;
    maintainers = with maintainers; [];
    platforms = ["x86_64-linux"];
  };
}
