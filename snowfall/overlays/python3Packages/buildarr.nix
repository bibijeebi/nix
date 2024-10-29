{
  lib,
  fetchPypi,
  python3Packages,
  poetry-core,
  ...
}:
python3Packages.buildPythonApplication rec {
  pname = "buildarr";
  version = "0.8.0b1";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-jUepr+7US5FLayBq+OQ9SivkxfaDu5fpo044TKeS6e4=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = with python3Packages; [
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

  pythonImportsCheck = ["buildarr"];

  meta = with lib; {
    description = "Constructs and configures Arr PVR stacks";
    homepage = "https://pypi.org/project/${pname}";
    license = licenses.gpl3Only;
    maintainers = [];
    mainProgram = pname;
  };
}
