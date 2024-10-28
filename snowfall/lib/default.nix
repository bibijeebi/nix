{
  lib,
  inputs,
}: {
  vscode-utils = {
    hasPackageLock = src: builtins.pathExists (src + "/package-lock.json");

    hasYarnLock = src: builtins.pathExists (src + "/yarn.lock");

    getExtensionInfo = src: let
      packageJson = builtins.fromJSON (builtins.readFile (src + "/package.json"));
    in {
      name = packageJson.name;
      version = packageJson.version;
      publisher = packageJson.publisher;
    };

    buildVSIX = src: let
      extInfo = getExtensionInfo src;
    in
      stdenv.mkDerivation {
        pname = extInfo.name;
        version = extInfo.version;

        inherit src;

        buildInputs = [
          nodejs
          nodePackages.vsce
        ];

        buildPhase = ''
          # Ensure we're in a writable directory for npm
          export HOME=$TMPDIR

          # Install dependencies
          ${
            if hasPackageLock src
            then "npm ci"
            else "npm install"
          }

          # Package the extension
          vsce package
        '';

        installPhase = ''
          # Find and copy the .vsix file to the output
          mkdir -p $out
          cp *.vsix $out/${extInfo.name}-${extInfo.version}.vsix
        '';

        # Prevent unnecessary rebuilds
        outputHashMode = "recursive";
        outputHashAlgo = "sha256";
      };
  };
}
