{
  ...
}: _final: prev: {
  qimgv = prev.qimgv.overrideAttrs (oldAttrs: {
    version = "1.0.3-alpha-128-gaeccf866";
    src = prev.fetchFromGitHub {
      owner = "easymodo";
      repo = "qimgv";
      rev = "aeccf866";
      sha256 = "sha256-24bsghJ74/w8t9MJj6R5IcexESFkARmMq6PBsm0er0Q=";
    };
    buildInputs = oldAttrs.buildInputs ++ [prev.libGL prev.libGLU];
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [prev.qt5.qttools];
    cmakeFlags = oldAttrs.cmakeFlags ++ ["-DUSE_OPENGL=ON" "-DOPENCV_SUPPORT=ON"];
  });
}
