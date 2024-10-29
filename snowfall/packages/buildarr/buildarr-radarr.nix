{
  python311,
  lib,
  fetchPypi,
  radarr-py,
  ...
}:
python311.pkgs.buildPythonApplication rec {
  pname = "buildarr-radarr";
  version = "0.2.6";
  format = "pyproject";

  src = fetchPypi {
    pname = "buildarr_radarr";
    inherit version;
    hash = "sha256-CdvRVGXrMm2IXTsJmGfz2RNeEcg0EX8GNj41pcCeMpM=";
  };

  nativeBuildInputs = with python311.pkgs; [
    poetry-core
  ];

  propagatedBuildInputs = with python311.pkgs; [
    buildarr
    packaging
    radarr-py
  ];

  pythonImportsCheck = ["buildarr_radarr"];

  meta = with lib; {
    description = "Radarr movie PVR plugin for Buildarr";
    homepage = "https://pypi.org/project/${pname}";
    license = licenses.gpl3Only;
    maintainers = [];
    mainProgram = pname;
  };
}
