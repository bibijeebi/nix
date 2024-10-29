{
  python311,
  fetchPypi,
  lib,
  buildarr,
  buildarr-radarr,
  buildarr-sonarr,
  ...
}:
python311.pkgs.buildPythonApplication rec {
  pname = "buildarr-jellyseerr";
  version = "0.3.2";
  format = "pyproject";

  src = fetchPypi {
    pname = "buildarr_jellyseerr";
    inherit version;
    hash = "sha256-Qq3P6rlTKYu95eUSfpK+Eyca2FWzu9A8SVc+N0JYLPg=";
  };

  nativeBuildInputs = with python311.pkgs; [
    setuptools
    poetry-core
  ];

  propagatedBuildInputs = [
    buildarr
  ];

  passthru.optional-dependencies = {
    radarr = [buildarr-radarr];
    sonarr = [buildarr-sonarr];
  };

  pythonImportsCheck = ["buildarr_jellyseerr"];

  meta = with lib; {
    description = "Jellyseerr media request library application plugin for Buildarr";
    homepage = "https://pypi.org/project/${pname}";
    license = licenses.gpl3Only;
    maintainers = [];
    mainProgram = pname;
  };
}
