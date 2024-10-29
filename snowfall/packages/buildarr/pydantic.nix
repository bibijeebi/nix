{
  lib,
  python,
  fetchPypi,
}:
with python.pkgs;
  buildPythonApplication rec {
    pname = "pydantic";
    version = "1.10.13";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-Msi0jc07KsTniwukrzosLrYEjLdSAvDqezT+t0Dvw0A=";
    };

    build-system = [
      setuptools
      wheel
    ];

    dependencies = [
      annotated-types
      pydantic-core
      typing-extensions
    ];

    optional-dependencies = [
      email-validator
      tzdata
    ];

    pythonImportsCheck = [
      "pydantic"
    ];

    meta = {
      description = "Data validation using Python type hints";
      homepage = "https://pypi.org/project/pydantic/1.10.13/";
      license = lib.licenses.mit;
      maintainers = [];
      mainProgram = "pydantic";
    };
  }
