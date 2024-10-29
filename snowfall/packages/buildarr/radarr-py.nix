{
  lib,
  fetchPypi,
  python,
  ...
}:
with python.pkgs;
  buildPythonApplication rec {
    pname = "radarr-py";
    version = "1.1.1";
    pyproject = true;

    src = fetchPypi {
      pname = "radarr_py";
      inherit version;
      hash = "sha256-ElN9gN1FPYMF0rovY/YJG7VqjYjWm6G8g3wj413JTFY=";
    };

    build-system = [
      setuptools
    ];

    dependencies = [
      pydantic
      python-dateutil
      typing-extensions
      urllib3
    ];

    pythonImportsCheck = [
      "radarr"
    ];

    meta = {
      description = "Radarr";
      homepage = "https://pypi.org/project/radarr-py/";
      license = with lib.licenses; [gpl3Only mpl20];
      maintainers = [];
      mainProgram = "radarr-py";
    };
  }