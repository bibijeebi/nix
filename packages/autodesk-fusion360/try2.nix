{
  lib,
  stdenv,
  makeWrapper,
  fetchurl,
  bash,
  curl,
  lsb-release,
  mesa-demos,
  polkit,
  wget,
  xdg-utils,
  p7zip,
  cabextract,
  samba,
  systemd,
  bc,
  xorg,
  mokutil,
  wine,
  winetricks,
  gettext,
  spacenavd,
}:
stdenv.mkDerivation rec {
  pname = "autodesk-fusion360-installer";
  version = "2.0.1-alpha";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/cryinkfly/Autodesk-Fusion-360-for-Linux/main/files/setup/autodesk_fusion_installer_x86-64.sh";
    sha256 = "0lsrp629n06qbgj52162jgr2ylcpz6w4nvjal9isyka2cw7hjz81";
  };

  dontUnpack = true;

  nativeBuildInputs = [makeWrapper];

  buildInputs = [
    bash
    curl
    lsb-release
    mesa-demos
    polkit
    wget
    xdg-utils
    p7zip
    cabextract
    samba
    systemd
    bc
    xorg.xrandr
    mokutil
    wine
    winetricks
    gettext
    spacenavd
  ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/locale

    # Copy the installer script
    cp $src $out/bin/fusion360-installer
    chmod +x $out/bin/fusion360-installer

    # Create required directories that the script expects
    mkdir -p $out/share/locale/update-locale.sh

    # Wrap the script with necessary environment variables and paths
    wrapProgram $out/bin/fusion360-installer \
      --prefix PATH : ${lib.makeBinPath buildInputs} \
      --prefix PATH : ${samba}/bin \
      --set TEXTDOMAINDIR "$out/share/locale" \
      --run "mkdir -p ~/.autodesk_fusion/locale" \
      --set HOME "$HOME"
  '';

  # Add setuid wrapper for pkexec
  requiresRoot = true;

  meta = with lib; {
    description = "Installer script for Autodesk Fusion 360 on Linux";
    homepage = "https://github.com/cryinkfly/Autodesk-Fusion-360-for-Linux";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = ["Steve Zabka"];
  };
}
