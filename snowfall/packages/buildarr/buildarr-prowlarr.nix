{
  lib,
  python311,
  fetchPypi,
  buildarr-radarr,
  buildarr-sonarr,
  ...
}:
python311.pkgs.buildPythonApplication rec {
  pname = "buildarr-prowlarr";
  version = "0.5.3";
  format = "pyproject";

  src = fetchPypi {
    pname = "buildarr_prowlarr";
    inherit version;
    hash = "sha256-v3QrQuleDxUKs46+TfQddQwbHN93WqictILVArFlG2I=";
  };

  nativeBuildInputs = with python311.pkgs; [
    poetry-core
  ];

  propagatedBuildInputs = with python311.pkgs; [
    buildarr
    json5
    packaging
    prowlarr-py
  ];

  passthru.optional-dependencies = {
    radarr = [buildarr-radarr];
    sonarr = [buildarr-sonarr];
  };

  pythonImportsCheck = ["buildarr_prowlarr"];

  meta = with lib; {
    description = "Prowlarr indexer manager plugin for Buildarr";
    homepage = "https://pypi.org/project/${pname}";
    license = licenses.gpl3Only;
    maintainers = [];
    mainProgram = pname;
  };
}
