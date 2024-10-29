{
  lib,
  fetchPypi,
  python,
  ...
}:
with python.pkgs;
  buildPythonApplication rec {
    pname = "buildarr-sonarr";
    version = "0.7.0b0";
    format = "pyproject";

    src = fetchPypi {
      pname = "buildarr_sonarr";
      inherit version;
      hash = "sha256-2DMQFDq/kZWNMytu1yCItpbpieqzrRc2kvczoB3iU/c=";
    };

    nativeBuildInputs = [
      poetry-core
    ];

    propagatedBuildInputs = [
      buildarr
      json5
    ];

    pythonImportsCheck = ["buildarr_sonarr"];

    meta = with lib; {
      description = "Sonarr PVR plugin for Buildarr";
      homepage = "https://pypi.org/project/${pname}";
      license = licenses.gpl3Only;
      maintainers = [];
      mainProgram = pname;
    };
  }
