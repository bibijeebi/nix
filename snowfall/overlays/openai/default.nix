# overlays/openai/default.nix
{ lib, ... }:

final: prev: {
  openai = prev.python3.pkgs.buildPythonPackage rec {
    pname = "openai";
    version = "1.52.0";

    src = prev.fetchFromGitHub {
      owner = "openai";
      repo = "openai-python";
      rev = "refs/tags/v${version}";
      hash = "sha256-5Km/9Eif7iLvIlAwvYZnGEZnIkjbMxLcPzHbkjEhTXQ=";
    };

    propagatedBuildInputs = with prev.python3.pkgs; [
      anyio
      distro
      httpx
      pydantic
      sniffio
      tqdm
      typing-extensions
      aiohttp
      requests
    ];

    # Required for API access
    makeWrapperArgs = [ "--set OPENAI_API_KEY \${OPENAI_API_KEY:-}" ];

    # The package has no tests
    doCheck = false;

    meta = with lib; {
      description = "The official Python library for the OpenAI API";
      homepage = "https://github.com/openai/openai-python";
      license = licenses.mit;
      maintainers = [ ];
    };

    passthru = {
      # Add Python environment with OpenAI for CLI usage
      env = prev.python3.withPackages (ps: [ final.openai ]);
    };
  };

  # Create a convenient CLI wrapper
  openai-cli = prev.writeScriptBin "openai-cli" ''
    #!${prev.bash}/bin/bash
    export PATH="${final.openai.env}/bin:$PATH"
    exec ${final.openai.env}/bin/python3 -m openai "$@"
  '';

  # Create a development environment
  openai-shell = prev.mkShell {
    packages = with final; [ openai openai-cli python3 ];

    shellHook = ''
      # Check for API key
      if [ -z "$OPENAI_API_KEY" ]; then
        echo "Warning: OPENAI_API_KEY environment variable is not set"
        echo "You can set it by running: export OPENAI_API_KEY='your-key-here'"
      fi
    '';
  };

  # Add Python package to default Python environment
  python3 = prev.python3.override {
    packageOverrides = python-self: python-super: { openai = final.openai; };
  };

  # Also create a version for Python 3.11 specifically
  python311 = prev.python311.override {
    packageOverrides = python-self: python-super: {
      openai = final.openai.override { python3 = prev.python311; };
    };
  };
}
