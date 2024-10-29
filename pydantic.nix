{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pydantic";
  version = "1.10.13";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Msi0jc07KsTniwukrzosLrYEjLdSAvDqezT+t0Dvw0A=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    annotated-types
    pydantic-core
    typing-extensions
  ];

  optional-dependencies = with python3.pkgs; {
    email = [
      email-validator
    ];
    timezone = [
      tzdata
    ];
  };

  pythonImportsCheck = [
    "pydantic"
  ];

  meta = {
    description = "Data validation using Python type hints";
    homepage = "https://pypi.org/project/pydantic/1.10.13/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "pydantic";
  };
}
