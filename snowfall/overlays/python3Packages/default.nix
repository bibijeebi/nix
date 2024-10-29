{...}: final: prev: {
  python311Packages = let
    inherit (prev) lib python3 fetchPypi;

    # Helper function to make package definitions more DRY
    mkBuildarrPackage = {
      pname,
      version,
      hash,
      build-system ? [python3.pkgs.poetry-core],
      dependencies ? [],
      optional-dependencies ? {},
      meta ? {},
      ...
    }:
      python3.pkgs.buildPythonApplication {
        inherit pname version;

        pyproject = true;
        format = "pyproject";

        src = fetchPypi {
          pname = lib.replaceStrings ["-"] ["_"] pname;
          inherit version hash;
        };

        inherit build-system dependencies optional-dependencies;

        pythonImportsCheck = [lib.replaceStrings ["-"] ["_"] pname];

        meta =
          {
            description = "Plugin for Buildarr";
            homepage = "https://pypi.org/project/${pname}";
            license = lib.licenses.gpl3Only;
            maintainers = [];
            mainProgram = pname;
          }
          // meta;
      };
  in
    prev.python311Packages
    // {
      buildarr = mkBuildarrPackage {
        pname = "buildarr";
        version = "0.8.0b1";
        hash = "sha256-jUepr+7US5FLayBq+OQ9SivkxfaDu5fpo044TKeS6e4=";
        build-system = [python3.pkgs.setuptools python3.pkgs.setuptools-scm];
        dependencies = with python3.pkgs; [
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
        meta.description = "Constructs and configures Arr PVR stacks";
      };

      buildarr-sonarr = mkBuildarrPackage {
        pname = "buildarr-sonarr";
        version = "0.7.0b0";
        hash = "sha256-2DMQFDq/kZWNMytu1yCItpbpieqzrRc2kvczoB3iU/c=";
        build-system = [python3.pkgs.setuptools python3.pkgs.setuptools-scm];
        dependencies = with python3.pkgs; [
          buildarr
          json5
        ];
        meta.description = "Sonarr PVR plugin for Buildarr";
      };

      buildarr-radarr = mkBuildarrPackage {
        pname = "buildarr-radarr";
        version = "0.2.6";
        hash = "sha256-CdvRVGXrMm2IXTsJmGfz2RNeEcg0EX8GNj41pcCeMpM=";
        dependencies = with python3.pkgs; [
          buildarr
          packaging
          radarr-py
        ];
        meta.description = "Radarr movie PVR plugin for Buildarr";
      };

      buildarr-prowlarr = mkBuildarrPackage {
        pname = "buildarr-prowlarr";
        version = "0.5.3";
        hash = "sha256-v3QrQuleDxUKs46+TfQddQwbHN93WqictILVArFlG2I=";
        dependencies = with python3.pkgs; [
          buildarr
          json5
          packaging
          prowlarr-py
        ];
        optional-dependencies = with python3.pkgs; {
          radarr = [buildarr-radarr];
          sonarr = [buildarr-sonarr];
        };
        meta.description = "Prowlarr indexer manager plugin for Buildarr";
      };

      buildarr-jellyseerr = mkBuildarrPackage {
        pname = "buildarr-jellyseerr";
        version = "0.3.2";
        hash = "sha256-Qq3P6rlTKYu95eUSfpK+Eyca2FWzu9A8SVc+N0JYLPg=";
        dependencies = with python3.pkgs; [
          buildarr
        ];
        optional-dependencies = with python3.pkgs; {
          radarr = [buildarr-radarr];
          sonarr = [buildarr-sonarr];
        };
        meta.description = "Jellyseerr media request library application plugin for Buildarr";
      };
    };
}
