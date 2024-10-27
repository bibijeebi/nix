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
  nodejs,
}: let
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

  buildChromeExtension = a @ {
    name ? "",
    pname ? name,
    version,
    src,
    manifestOverrides ? {},
    chromeExtId ? null,
    chromeExtPublisher ? null,
    chromeExtName ? null,
    nativeBuildInputs ? [],
    passthru ? {},
    ...
  }: let
    extensionId =
      if chromeExtId != null
      then chromeExtId
      else makeExtensionId (builtins.hashString "sha256" "${name}-${version}");
  in
    stdenv.mkDerivation (removeAttrs a ["manifestOverrides" "chromeExtId" "chromeExtPublisher" "chromeExtName"]
      // {
        inherit pname version src;
        name = "chrome-extension-${pname}-${version}";

        passthru =
          passthru
          // {
            inherit extensionId chromeExtPublisher chromeExtName;
          };

        nativeBuildInputs = [jq unzip zip nodejs] ++ nativeBuildInputs;

        patchPhase = ''
          runHook prePatch

          if [ -f "manifest.json" ]; then
            manifest=$(cat manifest.json)
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: ''
              manifest=$(echo "$manifest" | jq '. + {"${k}": ${builtins.toJSON v}}')
            '')
            manifestOverrides)}
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
          zip -r extension.zip ./*
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out/share/chrome-extensions
          cp -r . $out/share/chrome-extensions/unpacked
          cp extension.zip $out/share/chrome-extensions/extension.zip

          cat > $out/share/chrome-extensions/update.xml << EOF
          <?xml version='1.0' encoding='UTF-8'?>
          <gupdate xmlns='http://www.google.com/update2/response' protocol='2.0'>
            <app appid='${extensionId}'>
              <updatecheck
                codebase="file://$out/share/chrome-extensions/extension.zip"
                version="${version}"
                prodversionmin="${lib.versions.majorMinor version}"
              />
            </app>
          </gupdate>
          EOF

          runHook postInstall
        '';
      });

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

  toExtensionJsonEntry = ext: {
    id = ext.extensionId;
    version = ext.version;
    location = ext.outPath + "/share/chrome-extensions/extension.zip";
    updateUrl = "file://${ext.outPath}/share/chrome-extensions/update.xml";
  };

  toExtensionJson = extensions:
    builtins.toJSON (map toExtensionJsonEntry extensions);

  chromeEnv = import ./chromeEnv.nix {
    inherit lib buildEnv writeShellScriptBin extensionsFromChromeStore jq;
  };
in {
  inherit
    buildChromeExtension
    buildChromeStoreExtension
    fetchCrxFromChromeStore
    extensionFromChromeStore
    extensionsFromChromeStore
    toExtensionJsonEntry
    toExtensionJson
    ;
}
