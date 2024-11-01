{ qimgv, fetchFromGitHub, libGL, libGLU, qt5, }:
qimgv.overrideAttrs (oldAttrs: {
  version = "1.0.3-alpha-128-gaeccf866";
  src = fetchFromGitHub {
    owner = "easymodo";
    repo = "qimgv";
    rev = "aeccf866";
    sha256 = "sha256-24bsghJ74/w8t9MJj6R5IcexESFkARmMq6PBsm0er0Q=";
  };
  buildInputs = oldAttrs.buildInputs ++ [ libGL libGLU ];
  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ qt5.qttools ];
  cmakeFlags = oldAttrs.cmakeFlags
    ++ [ "-DUSE_OPENGL=ON" "-DOPENCV_SUPPORT=ON" ];
})
