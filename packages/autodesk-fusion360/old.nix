{
  lib,
  stdenv,
  fetchurl,
  wine-staging,
  winetricks,
  makeWrapper,
  writeShellScript,
  curl,
  p7zip,
  cabextract,
  samba,
  xdg-utils,
  mesa,
  fontconfig,
  writeTextFile,
  fetchWinetricks ? {
    name,
    sha256,
  }:
    fetchurl {
      url = "https://raw.githubusercontent.com/Winetricks/winetricks/master/files/${name}";
      inherit sha256;
    },
}:
stdenv.mkDerivation rec {
  pname = "autodesk-fusion360";
  version = "2.0.1";

  src = ./.;

  fusion360Installer = fetchurl {
    url = "https://dl.appstreaming.autodesk.com/production/installers/Fusion%20Admin%20Install.exe";
    name = "FusionAdminInstall.exe";
    sha256 = "1qcw1fbl2s9p8gwa0w6df9sscxnpkip3712sjd3qz6lv625xyb46";
  };

  webview2Installer = fetchurl {
    url = "https://github.com/aedancullen/webview2-evergreen-standalone-installer-archive/releases/download/109.0.1518.78/MicrosoftEdgeWebView2RuntimeInstallerX64.exe";
    name = "WebView2Installer.exe";
    sha256 = "0nzxp64qfn9yii1n7cywl8ym88kzli2ak7sdcva045127s34kk7j";
  };

  qt6WebEngineCore = fetchurl {
    url = "https://raw.githubusercontent.com/cryinkfly/Autodesk-Fusion-360-for-Linux/main/files/extras/patched-dlls/Qt6WebEngineCore.dll.7z";
    name = "Qt6WebEngineCore.dll.7z";
    sha256 = "1cll0g2vqsxasw7rhq0wxsb8qici4a29iaczdxahj5arlrlpjm62";
  };

  siappdll = fetchurl {
    url = "https://raw.githubusercontent.com/cryinkfly/Autodesk-Fusion-360-for-Linux/main/files/extras/patched-dlls/siappdll.dll";
    name = "siappdll.dll";
    sha256 = "1wy044ar27kyd7vq01axq0izw6hbkgjqacjgkshikxa3c5j6vs5a";
  };

  # Winetricks cached files
  winetricksFiles = {
    atmlib = fetchWinetricks {
      name = "atmlib.dll";
      sha256 = ""; # Add hash
    };
    # Add other required winetricks files here
  };

  nativeBuildInputs = [makeWrapper];

  buildInputs = [
    wine-staging
    winetricks
    curl
    p7zip
    cabextract
    samba
    xdg-utils
    mesa
    fontconfig
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    # Create directory structure
    mkdir -p $out/share/fusion360
    mkdir -p $out/bin
    mkdir -p $out/share/fusion360/cache/{winetricks,wine}
    mkdir -p $out/share/fusion360/temp

    # Set up environment
    export WINEPREFIX="$out/share/fusion360/wine"
    export HOME="$out/share/fusion360"
    export XDG_CACHE_HOME="$out/share/fusion360/cache"
    export XDG_DATA_HOME="$out/share/fusion360"
    export WINETRICKS_CACHE_DIR="$out/share/fusion360/cache/winetricks"
    export WINEDLLOVERRIDES="mscoree,mshtml="
    export FONTCONFIG_FILE=${fontconfig.out}/etc/fonts/fonts.conf
    export TMPDIR="$out/share/fusion360/temp"

    # Initialize wine prefix with staging
    ${wine-staging}/bin/wine wineboot

    # Copy winetricks cache files
    mkdir -p $WINETRICKS_CACHE_DIR
    ${lib.concatStrings (lib.mapAttrsToList (name: file: ''
        cp ${file} $WINETRICKS_CACHE_DIR/
      '')
      winetricksFiles)}

    # Install Windows components
    ${winetricks}/bin/winetricks -q win10
    ${winetricks}/bin/winetricks -q dotnet452
    ${winetricks}/bin/winetricks -q vcrun2017

    # Install WebView2
    cp ${webview2Installer} $WINEPREFIX/drive_c/webview2.exe
    ${wine-staging}/bin/wine $WINEPREFIX/drive_c/webview2.exe /silent /install

    # Install Fusion 360
    cp ${fusion360Installer} $WINEPREFIX/drive_c/fusion360.exe
    ${wine-staging}/bin/wine $WINEPREFIX/drive_c/fusion360.exe --quiet

    # Install patched DLLs
    7z x ${qt6WebEngineCore} -o"$WINEPREFIX/drive_c/Program Files/Autodesk/webengine"
    cp ${siappdll} "$WINEPREFIX/drive_c/Program Files/Autodesk"

    # Create launcher script
    makeWrapper ${writeShellScript "fusion360" ''
      export WINEPREFIX="$HOME/.local/share/fusion360/wine"
      export WINEDLLOVERRIDES="mscoree,mshtml="

      if [ ! -d "$WINEPREFIX" ]; then
        mkdir -p "$(dirname "$WINEPREFIX")"
        cp -r ${placeholder "out"}/share/fusion360/wine "$WINEPREFIX"
      fi

      exec ${wine-staging}/bin/wine "$WINEPREFIX/drive_c/Program Files/Autodesk/Fusion 360/Fusion360.exe" "$@"
    ''} $out/bin/fusion360 \
      --prefix PATH : ${lib.makeBinPath buildInputs} \
      --set FONTCONFIG_FILE ${fontconfig.out}/etc/fonts/fonts.conf
  '';

  meta = with lib; {
    description = "Autodesk Fusion 360 CAD/CAM software running via Wine";
    homepage = "https://www.autodesk.com/products/fusion-360/";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = with maintainers; [];
  };
}
