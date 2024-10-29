{
  lib,
  python3,
  fetchPypi,
  internal,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "buildarr";
  version = "0.7.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-FmYFChehwNYK7D+wBujuEBl02SxdKD7UBC7jGReeqnM=";
  };

  build-system = [
    python3.pkgs.poetry-core
  ];

  dependencies = with python3.pkgs; [
    aenum
    click
    internal.click-params
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
    homepage = "https://pypi.org/project/buildarr";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [];
    mainProgram = "buildarr";
  };
}
