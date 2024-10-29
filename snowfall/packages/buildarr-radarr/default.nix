{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "buildarr-radarr";
  version = "0.2.6";
  pyproject = true;

  src = fetchPypi {
    pname = "buildarr_radarr";
    inherit version;
    hash = "sha256-CdvRVGXrMm2IXTsJmGfz2RNeEcg0EX8GNj41pcCeMpM=";
  };

  build-system = [
    python3.pkgs.poetry-core
  ];

  dependencies = with python3.pkgs; [
    buildarr
    packaging
    radarr-py
  ];

  pythonImportsCheck = [
    "buildarr_radarr"
  ];

  meta = {
    description = "Radarr movie PVR plugin for Buildarr";
    homepage = "https://pypi.org/project/buildarr-radarr";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "buildarr-radarr";
  };
}
