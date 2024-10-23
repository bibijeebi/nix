{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  wine,
  winetricks,
  curl,
  p7zip,
  cabextract,
  samba,
  winbind,
  xdg-utils,
  mesa,
  bc,
  xorg,
  mokutil,
}:
stdenv.mkDerivation rec {
  pname = "autodesk-fusion360";
  version = "2.0.1-alpha"; # From installer script version

  src = fetchFromGitHub {
    owner = "cryinkfly";
    repo = "Autodesk-Fusion-360-for-Linux";
    rev = "v${version}";
    sha256 = ""; # Add hash after first attempt
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    wine
    winetricks
    curl
    p7zip
    cabextract
    samba
    winbind
    xdg-utils
    mesa
    bc
    xorg.xrandr
    mokutil
  ];

  installPhase = ''
    # Create directory structure
    mkdir -p $out/bin
    mkdir -p $out/share/${pname}

    # Copy installer script
    cp files/setup/autodesk_fusion_installer_x86-64.sh $out/share/${pname}/
    chmod +x $out/share/${pname}/autodesk_fusion_installer_x86-64.sh

    # Create wrapper script
    makeWrapper $out/share/${pname}/autodesk_fusion_installer_x86-64.sh $out/bin/fusion360 \
      --prefix PATH : ${lib.makeBinPath buildInputs} \
      --set WINEPREFIX "$HOME/.autodesk_fusion/wineprefixes/default"
  '';

  meta = with lib; {
    description = "Autodesk Fusion 360 running on Linux via Wine";
    homepage = "https://github.com/cryinkfly/Autodesk-Fusion-360-for-Linux";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [
      /*
      Add yourself
      */
    ];
  };
}
