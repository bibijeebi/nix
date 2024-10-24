# /lib/webext-utils/default.nix
{
  stdenv,
}: {
  # Function to build a Chrome extension package
  buildChromeExtension = {
    name,
    src,
    version,
    extensionId, # Chrome extension ID
    updateUrl ? "https://clients2.google.com/service/update2/crx",
    ...
  } @ attrs:
    stdenv.mkDerivation ({
        inherit name src version;

        installPhase = ''
          runHook preInstall

          # Create extension directory structure
          extDir="$out/share/chromium/extensions/${extensionId}"
          mkdir -p "$extDir"

          # Copy extension files
          cp -r ./* "$extDir/"

          # Create update manifest for manual installation
          mkdir -p "$out/share/chromium/policies/managed"
          cat > "$out/share/chromium/policies/managed/${extensionId}.json" <<EOF
          {
            "ExtensionInstallForcelist": ["${extensionId};${updateUrl}"]
          }
          EOF

          runHook postInstall
        '';

        passthru = {
          inherit extensionId updateUrl;
          # This allows the extension to be used in both formats:
          # As a full package for home-manager style
          chromiumExtension = {
            id = extensionId;
            inherit updateUrl;
          };
          # And as a string ID for NixOS module style
          extensionString = "${extensionId};${updateUrl}";
        };
      }
      // builtins.removeAttrs attrs ["name" "src" "version" "extensionId" "updateUrl"]);

  # Helper function to convert extension packages to the format needed by NixOS module
  extensionsToList = extensions:
    map (ext: ext.passthru.extensionString) extensions;
}
