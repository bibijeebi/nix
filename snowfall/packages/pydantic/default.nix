{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pydantic";
  version = "1.10.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-4TeI/K0br16zI2hWsqmnT32saz6nyh9gpK2LrUI5z0w=";
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
    homepage = "https://pypi.org/project/pydantic";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "pydantic";
  };
}
