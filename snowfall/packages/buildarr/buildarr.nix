{
  lib,
  python311,
  fetchPypi,
}:
python311.pkgs.buildPythonApplication rec {
  pname = "buildarr";
  version = "0.8.0b1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-jUepr+7US5FLayBq+OQ9SivkxfaDu5fpo044TKeS6e4=";
  };

  build-system = [
    python311.pkgs.setuptools
    python311.pkgs.setuptools-scm
  ];

  dependencies = with python311.pkgs; [
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
