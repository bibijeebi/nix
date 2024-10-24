# packages/webext-utils/default.nix
{
  lib,
  stdenv,
  buildEnv,
  writeShellScriptBin,
  fetchurl,
  jq,
  unzip,
  zip,
  crx3-utils,
}: let
  # Function to generate Chrome-compatible extension ID from a hash
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

  # Base builder for Chrome extensions
  buildChromeExtension = a @ {
    name ? "",
    manifestOverrides ? {},
    chromeExtId ? null, # Can be provided for known extensions
    chromeExtPublisher ? null,
    chromeExtName ? null,
    configurePhase ? ''
      runHook preConfigure
      runHook postConfigure
    '',
    buildPhase ? ''
      runHook preBuild
      runHook postBuild
    '',
    dontStrip ? true,
    nativeBuildInputs ? [],
    passthru ? {},
    ...
  }:
    stdenv.mkDerivation (a
      // {
        name = "chrome-extension-${name}";

        passthru =
          passthru
          // {
            inherit chromeExtPublisher chromeExtName;
            extensionId =
              if chromeExtId != null
              then chromeExtId
              else makeExtensionId (builtins.hashString "sha256" "${name}-${a.version}");
          };

        inherit configurePhase buildPhase dontStrip;

        nativeBuildInputs = [jq unzip zip crx3-utils] ++ nativeBuildInputs;

        patchPhase = ''
          runHook prePatch

          # Validate and patch manifest.json
          if [ -f "manifest.json" ]; then
            manifest=$(cat manifest.json)

            # Apply any overrides
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: ''
              manifest=$(echo "$manifest" | jq '. + {"${k}": ${builtins.toJSON v}}')
            '')
            manifestOverrides)}

            # Ensure the manifest is valid
            echo "$manifest" | jq 'empty'
            echo "$manifest" > manifest.json
          else
            echo "No manifest.json found"
            exit 1
          fi

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

          # Create extension directory
          mkdir -p $out/share/chrome-extensions

          # Install the extension files
          cp -r . $out/share/chrome-extensions/unpacked
          cp extension.zip $out/share/chrome-extensions/extension.zip
          cp extension.crx $out/share/chrome-extensions/extension.crx

          # Create update manifest
          cat > $out/share/chrome-extensions/update.xml << EOF
          <?xml version='1.0' encoding='UTF-8'?>
          <gupdate xmlns='http://www.google.com/update2/response' protocol='2.0'>
            <app appid='${passthru.extensionId}'>
              <updatecheck
                codebase="file://$out/share/chrome-extensions/extension.crx"
                version="${a.version}"
                prodversionmin="${lib.versions.majorMinor a.version}"
              />
            </app>
          </gupdate>
          EOF

          runHook postInstall
        '';
      });

  # Fetch extension CRX from Chrome Web Store
  fetchCrxFromChromeStore = {
    id,
    version,
    sha256,
  }:
    fetchurl {
      url =
        "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx3"
        + "&prodversion=${version}&x=id%3D${id}%26installsource%3Dondemand%26uc";
      inherit sha256;
      name = "chrome-extension-${id}.crx";
    };

  # Build extension from Chrome Web Store reference
  buildChromeStoreExtension = a @ {
    name ? "",
    src ? null,
    crx ? null,
    storeRef,
    ...
  }:
    assert "" == name;
    assert null == src;
      buildChromeExtension (
        (removeAttrs a ["storeRef" "crx"])
        // {
          name = "${storeRef.id}-${storeRef.version}";
          version = storeRef.version;
          src =
            if (crx != null)
            then crx
            else fetchCrxFromChromeStore storeRef;
          chromeExtId = storeRef.id;
        }
      );

  # Helper functions for store extensions
  storeRefAttrList = [
    "id"
    "version"
    "sha256"
    "publisher"
    "name"
  ];

  storeExtRefToExtDrv = ext:
    buildChromeStoreExtension (
      removeAttrs ext storeRefAttrList
      // {
        storeRef = builtins.intersectAttrs (lib.genAttrs storeRefAttrList (_: null)) ext;
      }
    );

  extensionFromChromeStore = storeExtRefToExtDrv;
  extensionsFromChromeStore = storeRefList:
    builtins.map extensionFromChromeStore storeRefList;

  # Helper to generate extension metadata for Chrome
  toExtensionJsonEntry = ext: {
    id = ext.extensionId;
    version = ext.version;
    location = ext.outPath + "/share/chrome-extensions/extension.crx";
    updateUrl = "file://${ext.outPath}/share/chrome-extensions/update.xml";
  };

  toExtensionJson = extensions:
    builtins.toJSON (map toExtensionJsonEntry extensions);

  # Helper to convert Chrome Store extensions to Nix expressions
  chromeExts2nix = {
  }:
    writeShellScriptBin "chrome-exts-2-nix" ''
      #!${stdenv.shell}

      # TODO: Implement scraping of Chrome Web Store
      # This would need to:
      # 1. Fetch extension metadata from store
      # 2. Generate Nix expressions
      # 3. Save to outputFile
      echo "Not implemented yet"
      exit 1
    '';

  # Environment builder for Chrome with extensions
  chromeEnv = import ./chromeEnv.nix {
    inherit
      lib
      buildEnv
      writeShellScriptBin
      extensionsFromChromeStore
      jq
      ;
  };
in {
  inherit
    buildChromeExtension
    buildChromeStoreExtension
    fetchCrxFromChromeStore
    extensionFromChromeStore
    extensionsFromChromeStore
    chromeExts2nix
    chromeEnv
    toExtensionJsonEntry
    toExtensionJson
    ;
}
