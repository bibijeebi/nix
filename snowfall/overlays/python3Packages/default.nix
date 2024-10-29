final: prev: {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (python-final: python-prev: {
        buildarr = python-prev.buildPythonApplication rec {
          pname = "buildarr";
          version = "0.8.0b1";
          format = "pyproject";

          src = final.fetchPypi {
            inherit pname version;
            hash = "sha256-jUepr+7US5FLayBq+OQ9SivkxfaDu5fpo044TKeS6e4=";
          };

          nativeBuildInputs = with python-final; [
            setuptools
            setuptools-scm
          ];

          propagatedBuildInputs = with python-final; [
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

          pythonImportsCheck = ["buildarr"];

          meta = with final.lib; {
            description = "Constructs and configures Arr PVR stacks";
            homepage = "https://pypi.org/project/${pname}";
            license = licenses.gpl3Only;
            maintainers = [];
            mainProgram = pname;
          };
        };

        buildarr-sonarr = python-prev.buildPythonApplication rec {
          pname = "buildarr-sonarr";
          version = "0.7.0b0";
          format = "pyproject";

          src = final.fetchPypi {
            pname = "buildarr_sonarr";
            inherit version;
            hash = "sha256-2DMQFDq/kZWNMytu1yCItpbpieqzrRc2kvczoB3iU/c=";
          };

          nativeBuildInputs = with python-final; [
            setuptools
            setuptools-scm
          ];

          propagatedBuildInputs = with python-final; [
            buildarr
            json5
          ];

          pythonImportsCheck = ["buildarr_sonarr"];

          meta = with final.lib; {
            description = "Sonarr PVR plugin for Buildarr";
            homepage = "https://pypi.org/project/${pname}";
            license = licenses.gpl3Only;
            maintainers = [];
            mainProgram = pname;
          };
        };

        buildarr-radarr = python-prev.buildPythonApplication rec {
          pname = "buildarr-radarr";
          version = "0.2.6";
          format = "pyproject";

          src = final.fetchPypi {
            pname = "buildarr_radarr";
            inherit version;
            hash = "sha256-CdvRVGXrMm2IXTsJmGfz2RNeEcg0EX8GNj41pcCeMpM=";
          };

          nativeBuildInputs = with python-final; [
            poetry-core
          ];

          propagatedBuildInputs = with python-final; [
            buildarr
            packaging
            radarr-py
          ];

          pythonImportsCheck = ["buildarr_radarr"];

          meta = with final.lib; {
            description = "Radarr movie PVR plugin for Buildarr";
            homepage = "https://pypi.org/project/${pname}";
            license = licenses.gpl3Only;
            maintainers = [];
            mainProgram = pname;
          };
        };

        buildarr-prowlarr = python-prev.buildPythonApplication rec {
          pname = "buildarr-prowlarr";
          version = "0.5.3";
          format = "pyproject";

          src = final.fetchPypi {
            pname = "buildarr_prowlarr";
            inherit version;
            hash = "sha256-v3QrQuleDxUKs46+TfQddQwbHN93WqictILVArFlG2I=";
          };

          nativeBuildInputs = with python-final; [
            poetry-core
          ];

          propagatedBuildInputs = with python-final; [
            buildarr
            json5
            packaging
            prowlarr-py
          ];

          passthru.optional-dependencies = with python-final; {
            radarr = [buildarr-radarr];
            sonarr = [buildarr-sonarr];
          };

          pythonImportsCheck = ["buildarr_prowlarr"];

          meta = with final.lib; {
            description = "Prowlarr indexer manager plugin for Buildarr";
            homepage = "https://pypi.org/project/${pname}";
            license = licenses.gpl3Only;
            maintainers = [];
            mainProgram = pname;
          };
        };

        buildarr-jellyseerr = python-prev.buildPythonApplication rec {
          pname = "buildarr-jellyseerr";
          version = "0.3.2";
          format = "pyproject";

          src = final.fetchPypi {
            pname = "buildarr_jellyseerr";
            inherit version;
            hash = "sha256-Qq3P6rlTKYu95eUSfpK+Eyca2FWzu9A8SVc+N0JYLPg=";
          };

          nativeBuildInputs = with python-final; [
            poetry-core
          ];

          propagatedBuildInputs = with python-final; [
            buildarr
          ];

          passthru.optional-dependencies = with python-final; {
            radarr = [buildarr-radarr];
            sonarr = [buildarr-sonarr];
          };

          pythonImportsCheck = ["buildarr_jellyseerr"];

          meta = with final.lib; {
            description = "Jellyseerr media request library application plugin for Buildarr";
            homepage = "https://pypi.org/project/${pname}";
            license = licenses.gpl3Only;
            maintainers = [];
            mainProgram = pname;
          };
        };
      })
    ];
}
