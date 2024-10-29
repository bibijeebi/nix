{
  lib,
  python3,
  fetchPypi,
  internal,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "click-params";
  version = "0.5.0";
  pyproject = true;

  src = fetchPypi {
    pname = "click_params";
    inherit version;
    hash = "sha256-X+l7lFl4GjtDuE/k7ABlGT4bDVz23HeJf+IMMfR41/8=";
  };

  build-system = [
    python3.pkgs.poetry-core
  ];

  dependencies = with python3.pkgs; [
    click
    deprecated
    internal.validators
  ];

  pythonImportsCheck = [
    "click_params"
  ];

  meta = {
    description = "A bunch of useful click parameter types";
    homepage = "https://pypi.org/project/click-params";
    license = lib.licenses.asl20;
    maintainers = [];
    mainProgram = "click-params";
  };
}
