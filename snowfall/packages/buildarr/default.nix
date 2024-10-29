{
  lib,
  callPackage,
  python311,
  fetchPypi,
  ...
}: let
  python = python311;

  prowlarr-py = callPackage ./prowlarr-py.nix {inherit lib python fetchPypi;};
  radarr-py = callPackage ./radarr-py.nix {inherit lib python fetchPypi;};
  buildarr-radarr = callPackage ./buildarr-radarr.nix {inherit lib python fetchPypi radarr-py;};
  buildarr-sonarr = callPackage ./buildarr-sonarr.nix {inherit lib python fetchPypi;};
  buildarr-prowlarr = callPackage ./buildarr-prowlarr.nix {inherit lib python fetchPypi prowlarr-py buildarr-radarr buildarr-sonarr;};
  buildarr-jellyseerr = callPackage ./buildarr-jellyseerr.nix {inherit lib python fetchPypi buildarr-radarr buildarr-sonarr;};
in
  with python.pkgs;
    buildPythonApplication rec {
      pname = "buildarr";
      version = "0.8.0b1";
      format = "pyproject";

      src = fetchPypi {
        inherit pname version;
        hash = "sha256-jUepr+7US5FLayBq+OQ9SivkxfaDu5fpo044TKeS6e4=";
      };

      nativeBuildInputs = [
        setuptools
        setuptools-scm
      ];

      propagatedBuildInputs = [
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
        # Add the plugins as dependencies
        buildarr-radarr
        buildarr-sonarr
        buildarr-prowlarr
        buildarr-jellyseerr
      ];

      pythonImportsCheck = [
        "buildarr"
      ];

      meta = with lib; {
        description = "Constructs and configures Arr PVR stacks";
        homepage = "https://pypi.org/project/buildarr/";
        license = licenses.gpl3Only;
        maintainers = [];
        mainProgram = "buildarr";
      };
    }
