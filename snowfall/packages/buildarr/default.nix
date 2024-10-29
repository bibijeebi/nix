{
  lib,
  python3,
  fetchPypi,
  ...
}: let
  buildarr-radarr = python3.pkgs.buildPythonApplication rec {
    pname = "buildarr-radarr";
    version = "0.2.6";
    pyproject = true;
    src = fetchPypi {
      pname = "buildarr_radarr";
      inherit version;
      hash = "sha256-CdvRVGXrMm2IXTsJmGfz2RNeEcg0EX8GNj41pcCeMpM=";
    };
    build-system = [python3.pkgs.poetry-core];
    dependencies = with python3.pkgs; [buildarr packaging radarr-py];
    pythonImportsCheck = ["buildarr_radarr"];
    meta = {
      description = "Radarr movie PVR plugin for Buildarr";
      homepage = "https://pypi.org/project/buildarr-radarr";
      license = lib.licenses.gpl3Only;
      maintainers = [];
      mainProgram = "buildarr-radarr";
    };
  };
  buildarr-jellyseerr = python3.pkgs.buildPythonApplication rec {
    pname = "buildarr-jellyseerr";
    version = "0.3.2";
    pyproject = true;
    src = fetchPypi {
      pname = "buildarr_jellyseerr";
      inherit version;
      hash = "sha256-Qq3P6rlTKYu95eUSfpK+Eyca2FWzu9A8SVc+N0JYLPg=";
    };
    build-system = [python3.pkgs.poetry-core];
    dependencies = [python3.pkgs.buildarr];
    optional-dependencies = with python3.pkgs; {
      radarr = [buildarr-radarr];
      sonarr = [buildarr-sonarr];
    };
    pythonImportsCheck = ["buildarr_jellyseerr"];
    meta = {
      description = "Jellyseerr media request library application plugin for Buildarr";
      homepage = "https://pypi.org/project/buildarr-jellyseerr";
      license = lib.licenses.gpl3Only;
      maintainers = [];
      mainProgram = "buildarr-jellyseerr";
    };
  };
  buildarr-prowlarr = python3.pkgs.buildPythonApplication rec {
    pname = "buildarr-prowlarr";
    version = "0.5.3";
    pyproject = true;
    src = fetchPypi {
      pname = "buildarr_prowlarr";
      inherit version;
      hash = "sha256-v3QrQuleDxUKs46+TfQddQwbHN93WqictILVArFlG2I=";
    };
    build-system = [python3.pkgs.poetry-core];
    dependencies = [python3.pkgs.buildarr python3.pkgs.json5 python3.pkgs.packaging python3.pkgs.prowlarr-py];
    optional-dependencies = with python3.pkgs; {
      radarr = [buildarr-radarr];
      sonarr = [buildarr-sonarr];
    };
    pythonImportsCheck = ["buildarr_prowlarr"];
    meta = {
      description = "Prowlarr indexer manager plugin for Buildarr";
      homepage = "https://pypi.org/project/buildarr-prowlarr";
      license = lib.licenses.gpl3Only;
      maintainers = [];
      mainProgram = "buildarr-prowlarr";
    };
  };
  buildarr-sonarr = python3.pkgs.buildPythonApplication rec {
    pname = "buildarr-sonarr";
    version = "0.7.0b0";
    pyproject = true;
    src = fetchPypi {
      pname = "buildarr_sonarr";
      inherit version;
      hash = "sha256-2DMQFDq/kZWNMytu1yCItpbpieqzrRc2kvczoB3iU/c=";
    };
    build-system = [python3.pkgs.setuptools python3.pkgs.setuptools-scm];
    dependencies = [python3.pkgs.buildarr python3.pkgs.json5];
    pythonImportsCheck = ["buildarr_sonarr"];
    meta = {
      description = "Sonarr PVR plugin for Buildarr";
      homepage = "https://pypi.org/project/buildarr-sonarr";
      license = lib.licenses.gpl3Only;
      maintainers = [];
      mainProgram = "buildarr-sonarr";
    };
  };
  buildarr = python3.pkgs.buildPythonApplication rec {
    pname = "buildarr";
    version = "0.8.0b1";
    pyproject = true;
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-jUepr+7US5FLayBq+OQ9SivkxfaDu5fpo044TKeS6e4=";
    };
    build-system = [python3.pkgs.setuptools python3.pkgs.setuptools-scm];
    dependencies = with python3.pkgs; [aenum click importlib-metadata pydantic pyyaml requests schedule stevedore typing-extensions watchdog];
    pythonImportsCheck = ["buildarr"];
    meta = {
      description = "Constructs and configures Arr PVR stacks";
      homepage = "https://pypi.org/project/buildarr";
      license = lib.licenses.gpl3Only;
      maintainers = [];
      mainProgram = "buildarr";
    };
  };
in
  python3.withPackages (ps: [buildarr buildarr-jellyseerr buildarr-prowlarr buildarr-sonarr])
