# packages/webext-utils/default.nix
{
  lib,
  stdenv,
  writeText,
  jq,
  zip,
  crx3-utils, # We'll need to add this as a dependency
}: let
  # Keep existing makeExtensionId function
  makeExtensionId = hash: let
    base16ToBase16Limited = c:
      if c == "0"
      then "a"
      else if c == "1"
      then "b"
      else if c == "2"
      then "c"
      else if c == "3"
      then "d"
      else if c == "4"
      then "e"
      else if c == "5"
      then "f"
      else if c == "6"
      then "g"
      else if c == "7"
      then "h"
      else if c == "8"
      then "i"
      else if c == "9"
      then "j"
      else if c == "a"
      then "k"
      else if c == "b"
      then "l"
      else if c == "c"
      then "m"
      else if c == "d"
      then "n"
      else if c == "e"
      then "o"
      else if c == "f"
      then "p"
      else "a";
  in
    lib.concatStrings (map base16ToBase16Limited (lib.stringToCharacters (builtins.substring 0 32 hash)));

  # New function to validate manifest.json
in {
  buildChromeExtension = {
    pname,
    version,
    src,
    manifestOverrides ? {},
    buildInputs ? [],
    nativeBuildInputs ? [],
    postPatch ? "",
    meta ? {},
    ...
  } @ attrs: let
    extensionId = makeExtensionId (builtins.hashString "sha256" "${pname}-${version}");

    extension = stdenv.mkDerivation (attrs
      // {
        inherit pname version src meta;

        nativeBuildInputs = [jq zip crx3-utils] ++ nativeBuildInputs;
        buildInputs = buildInputs;

        patchPhase = ''
          runHook prePatch

          # Read and validate manifest
          if [ -f "manifest.json" ]; then
            manifest=$(cat manifest.json)
            # Apply any overrides
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: ''
              manifest=$(echo "$manifest" | jq '. + {"${k}": ${builtins.toJSON v}}')
            '')
            manifestOverrides)}

            # Ensure the manifest is valid
            echo "$manifest" | jq 'empty'

            # Write back the modified manifest
            echo "$manifest" > manifest.json
          else
            echo "No manifest.json found"
            exit 1
          fi

          ${postPatch}
          runHook postPatch
        '';

        buildPhase = ''
          runHook preBuild

          # Package the extension
          zip -r extension.zip ./*

          # Convert to CRX3 format
          crx3-utils pack --zip extension.zip --output extension.crx

          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          # Install the extension files
          mkdir -p $out/share/chrome-extensions/${extensionId}
          cp -r . $out/share/chrome-extensions/${extensionId}/

          # Install the packaged extensions
          cp extension.zip $out/share/chrome-extensions/${extensionId}.zip
          cp extension.crx $out/share/chrome-extensions/${extensionId}.crx

          runHook postInstall
        '';

        passthru = {
          inherit extensionId;

          # Generate the update manifest XML
          updateManifest = writeText "update-manifest.xml" ''
            <?xml version='1.0' encoding='UTF-8'?>
            <gupdate xmlns='http://www.google.com/update2/response' protocol='2.0'>
              <app appid='${extensionId}'>
                <updatecheck
                  codebase="file://${extension}/share/chrome-extensions/${extensionId}.crx"
                  version="${version}"
                  prodversionmin="${lib.versions.majorMinor version}"
                />
              </app>
            </gupdate>
          '';

          # The string to use in chromium.extensions
          extensionString = "${extensionId};file://${extension.updateManifest}";
        };
      });
  in
    extension;

  # Helper function to fetch extension from Chrome Web Store
  fetchChromeExtension = {
    ...
  }:
    throw "Not implemented yet - will fetch from Chrome Web Store";

  # Helper to convert Chrome Web Store extensions to Nix
  chromeExts2nix = {
  }:
    throw "Not implemented yet - will generate Nix expressions from extension IDs";
}
