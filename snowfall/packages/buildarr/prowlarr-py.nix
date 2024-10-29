{
  lib,
  fetchPypi,
  python,
  ...
}:
with python.pkgs;
  buildPythonApplication rec {
    pname = "prowlarr-py";
    version = "1.0.2";
    pyproject = true;

    src = fetchPypi {
      pname = "prowlarr_py";
      inherit version;
      hash = "sha256-x3nHb5e/Sb6ML/ES7X/TTn8TAfjDuntGFUtT/BN9Vtk=";
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
      "prowlarr"
    ];

    meta = {
      description = "Prowlarr";
      homepage = "https://pypi.org/project/prowlarr-py/";
      license = with lib.licenses; [gpl3Only mpl20];
      maintainers = [];
      mainProgram = "prowlarr-py";
    };
  }
