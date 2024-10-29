{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system} = with pkgs; rec {
      prowlarr-py = python311Packages.buildPythonApplication rec {
        pname = "prowlarr-py";
        version = "1.0.2";
        pyproject = true;

        src = fetchPypi {
          pname = "prowlarr_py";
          inherit version;
          hash = "sha256-x3nHb5e/Sb6ML/ES7X/TTn8TAfjDuntGFUtT/BN9Vtk=";
        };

        build-system = [
          python311.pkgs.setuptools
        ];

        dependencies = with python311.pkgs; [
          pydantic
          python-dateutil
          typing-extensions
          urllib3
        ];

        pythonImportsCheck = [
          "prowlarr"
        ];

        meta = {
          description = "Prowlarr";
          homepage = "https://pypi.org/project/prowlarr-py/";
          license = with lib.licenses; [gpl3Only mpl20];
          maintainers = [];
          mainProgram = "prowlarr-py";
        };
      };

      radarr-py = python311Packages.buildPythonApplication rec {
        pname = "radarr-py";
        version = "1.1.1";
        pyproject = true;

        src = fetchPypi {
          pname = "radarr_py";
          inherit version;
          hash = "sha256-ElN9gN1FPYMF0rovY/YJG7VqjYjWm6G8g3wj413JTFY=";
        };

        build-system = [
          python311Packages.setuptools
        ];

        dependencies = with python311Packages; [
          pydantic
          python-dateutil
          typing-extensions
          urllib3
        ];

        pythonImportsCheck = [
          "radarr"
        ];

        meta = {
          description = "Radarr";
          homepage = "https://pypi.org/project/radarr-py/";
          license = with lib.licenses; [gpl3Only mpl20];
          maintainers = [];
          mainProgram = "radarr-py";
        };
      };

      buildarr = python311Packages.buildPythonApplication rec {
        pname = "buildarr";
        version = "0.8.0b1";
        pyproject = true;

        src = fetchPypi {
          inherit pname version;
          hash = "sha256-jUepr+7US5FLayBq+OQ9SivkxfaDu5fpo044TKeS6e4=";
        };

        build-system = [
          python311.pkgs.setuptools
          python311.pkgs.setuptools-scm
        ];

        dependencies = with python311.pkgs; [
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

        pythonImportsCheck = [
          "buildarr"
        ];

        meta = {
          description = "Constructs and configures Arr PVR stacks";
          homepage = "https://pypi.org/project/buildarr/";
          license = lib.licenses.gpl3Only;
          maintainers = with lib.maintainers; [];
          mainProgram = "buildarr";
        };
      };

      buildarr-jellyseerr = python311Packages.buildPythonApplication rec {
        pname = "buildarr-jellyseerr";
        version = "0.3.2";
        format = "pyproject";

        src = fetchPypi {
          pname = "buildarr_jellyseerr";
          inherit version;
          hash = "sha256-Qq3P6rlTKYu95eUSfpK+Eyca2FWzu9A8SVc+N0JYLPg=";
        };

        nativeBuildInputs = with python311Packages; [
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
      };
      buildarr-prowlarr = python311Packages.buildPythonApplication rec {
        pname = "buildarr-prowlarr";
        version = "0.5.3";
        format = "pyproject";

        src = fetchPypi {
          pname = "buildarr_prowlarr";
          inherit version;
          hash = "sha256-v3QrQuleDxUKs46+TfQddQwbHN93WqictILVArFlG2I=";
        };

        nativeBuildInputs = with python311Packages; [
          poetry-core
        ];

        propagatedBuildInputs = with python311Packages; [
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
      };
      buildarr-radarr = python311Packages.buildPythonApplication rec {
        pname = "buildarr-radarr";
        version = "0.2.6";
        format = "pyproject";

        src = fetchPypi {
          pname = "buildarr_radarr";
          inherit version;
          hash = "sha256-CdvRVGXrMm2IXTsJmGfz2RNeEcg0EX8GNj41pcCeMpM=";
        };

        nativeBuildInputs = with python311Packages; [
          poetry-core
        ];

        propagatedBuildInputs = with python311Packages; [
          buildarr
          packaging
          radarr-py
        ];

        pythonImportsCheck = ["buildarr_radarr"];

        meta = with lib; {
          description = "Radarr movie PVR plugin for Buildarr";
          homepage = "https://pypi.org/project/${pname}";
          license = licenses.gpl3Only;
          maintainers = [];
          mainProgram = pname;
        };
      };
      buildarr-sonarr = python311Packages.buildPythonApplication rec {
        pname = "buildarr-sonarr";
        version = "0.7.0b0";
        format = "pyproject";

        src = fetchPypi {
          pname = "buildarr_sonarr";
          inherit version;
          hash = "sha256-2DMQFDq/kZWNMytu1yCItpbpieqzrRc2kvczoB3iU/c=";
        };

        nativeBuildInputs = with python311Packages; [
          poetry-core
        ];

        propagatedBuildInputs = with python311Packages; [
          buildarr
          json5
        ];

        pythonImportsCheck = ["buildarr_sonarr"];

        meta = with lib; {
          description = "Sonarr PVR plugin for Buildarr";
          homepage = "https://pypi.org/project/${pname}";
          license = licenses.gpl3Only;
          maintainers = [];
          mainProgram = pname;
        };
      };
      default = self.packages.${system}.buildarr;
    };
  };
}
