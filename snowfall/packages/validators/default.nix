{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "validators";
  version = "0.22.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-d7Jomxcu7rYA2WBauGGUZBZwzbc7YK/VdxQqk5eHM3A=";
  };

  build-system = [
    python3.pkgs.setuptools
  ];

  optional-dependencies = with python3.pkgs; {
    docs-offline = [
      myst-parser
      pypandoc-binary
      sphinx
    ];
    docs-online = [
      mkdocs
      mkdocs-git-revision-date-localized-plugin
      mkdocs-material
      mkdocstrings
      pyaml
    ];
    hooks = [
      pre-commit
    ];
    package = [
      build
      twine
    ];
    runner = [
      tox
    ];
    sast = [
      bandit
    ];
    testing = [
      pytest
    ];
    tooling = [
      black
      pyright
      ruff
    ];
    tooling-extras = [
      pyaml
      pypandoc-binary
      pytest
    ];
  };

  pythonImportsCheck = [
    "validators"
  ];

  meta = {
    description = "Python Data Validation for Humans";
    homepage = "https://pypi.org/project/validators";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "validators";
  };
}
