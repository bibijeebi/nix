{
  lib,
  fetchPypi,
  python,
}:
with python.pkgs;
  buildPythonApplication rec {
    pname = "buildarr";
    version = "0.8.0b1";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-jUepr+7US5FLayBq+OQ9SivkxfaDu5fpo044TKeS6e4=";
    };

    build-system = [
      setuptools
      setuptools-scm
    ];

    dependencies = [
      aenum
      click
      importlib-metadata
      pydantic
      pyyaml
      requests
      schedule
      stevedore
      typing-extensions
      watchdog
    ];

    pythonImportsCheck = [
      "buildarr"
    ];

    meta = {
      description = "Constructs and configures Arr PVR stacks";
      homepage = "https://pypi.org/project/buildarr/";
      license = lib.licenses.gpl3Only;
      maintainers = [];
      mainProgram = "buildarr";
    };
  }
