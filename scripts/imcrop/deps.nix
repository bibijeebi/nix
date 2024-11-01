with import <nixpkgs> { };
let
  python = python312;
  pythonPackages = python.pkgs;

  mediapipe = pythonPackages.buildPythonPackage rec {
    pname = "mediapipe";
    version = "0.10.15";
    format = "wheel";

    src = fetchurl {
      url =
        "https://files.pythonhosted.org/packages/5e/c1/20447696a967b07f5bf9c77cf037b5d06d26e596daf416170e6cfca79613/mediapipe-0.10.15-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
      sha256 = "sha256-x/7lCI32jy86tE9ojgWe+FhZZp+DByB8vhkzenw1uLk=";
    };

    nativeBuildInputs = [ autoPatchelfHook stdenv.cc.cc.lib ];

    buildInputs = [
      stdenv.cc.cc.lib
      mesa
      libGL
      xorg.libX11
      xorg.libXrender
      xorg.libxcb
      libGLU
    ];

    propagatedBuildInputs = with pythonPackages; [
      numpy
      protobuf
      absl-py
      attrs
      matplotlib
      opencv4
    ];

    doCheck = false;
    pythonImportsCheck = [ "mediapipe" ];

    autoPatchelfIgnoreMissingDeps = true;
  };

  opencv-python-headless = pythonPackages.buildPythonApplication rec {
    pname = "opencv-python-headless";
    version = "4.10.0.84";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-8gF8YQHXwu+Ne8O0FMN/9/VNZEE6GEfYmXC2twabTho=";
    };

    build-system = [
      python3.pkgs.cmake
      python3.pkgs.numpy
      python3.pkgs.pip
      python3.pkgs.scikit-build
      python3.pkgs.setuptools
    ];

    dependencies = with python3.pkgs; [ numpy ];

    pythonImportsCheck = [ "opencv_python_headless" ];

    meta = {
      description = "Wrapper package for OpenCV python bindings";
      homepage = "https://pypi.org/project/opencv-python-headless";
      license = with lib.licenses; [ asl20 mit ];
      maintainers = with lib.maintainers; [ ];
      mainProgram = "opencv-python-headless";
    };
  };
in python.withPackages (ps: [ mediapipe opencv-python-headless ])
