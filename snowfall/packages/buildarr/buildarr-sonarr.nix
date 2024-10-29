{
  python311,
  lib,
  fetchPypi,
  ...
}:
python311.pkgs.buildPythonApplication rec {
  pname = "buildarr-sonarr";
  version = "0.7.0b0";
  format = "pyproject";

  src = fetchPypi {
    pname = "buildarr_sonarr";
    inherit version;
    hash = "sha256-2DMQFDq/kZWNMytu1yCItpbpieqzrRc2kvczoB3iU/c=";
  };

  nativeBuildInputs = with python311.pkgs; [
    poetry-core
  ];

  propagatedBuildInputs = with python311.pkgs; [
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
