# packages/webext-utils/default.nix
{
  lib,
  stdenv,
  writeText,
  nodejs,
}: let
  # Function to generate a Chrome-compatible extension ID from a hash
  makeExtensionId = hash: let
    # Chrome extension IDs are 32 chars, lowercase a-p
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
in {
  buildChromeExtension = {
    pname,
    version,
    src,
    meta ? {},
    ...
  } @ attrs: let
    extensionId = makeExtensionId (builtins.hashString "sha256" "${pname}-${version}");

    # Build the actual extension
    extension = stdenv.mkDerivation ({
        inherit pname version src meta;

        installPhase = ''
          mkdir -p $out/share/chrome-extensions/${extensionId}
          cp -r . $out/share/chrome-extensions/${extensionId}/

          # Create CRX file if needed
          # ${nodejs}/bin/node ${./pack-extension.js} $out/share/chrome-extensions/${extensionId} $out/share/chrome-extensions/${extensionId}.crx
        '';

        passthru = {
          inherit extensionId;

          # Generate the update manifest XML
          updateManifest = writeText "update-manifest.xml" ''
            <?xml version='1.0' encoding='UTF-8'?>
            <gupdate xmlns='http://www.google.com/update2/response' protocol='2.0'>
              <app appid='${extensionId}'>
                <updatecheck codebase="file://${extension}/share/chrome-extensions/${extensionId}.crx" version="${version}" />
              </app>
            </gupdate>
          '';

          # The string to use in chromium.extensions
          extensionString = "${extensionId};file://${extension.updateManifest}";
        };
      }
      // builtins.removeAttrs attrs ["pname" "version" "src" "meta"]);
  in
    extension;
}
