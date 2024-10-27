# packages/webext-utils/chromeEnv.nix
{
  lib,
  buildEnv,
  writeShellScriptBin,
  extensionsFromChromeStore,
  jq,
}: {
  name ? "chrome-with-extensions",
  extensions ? [],
  chromium,
}: let
  # Convert extension list to the format Chrome expects
  extensionDrvs = extensionsFromChromeStore extensions;

  # Create environment with extensions
  env = buildEnv {
    name = "chrome-environment-${name}";
    paths = [chromium] ++ extensionDrvs;

    # Merge extension metadata
    postBuild = ''
      mkdir -p $out/share/chrome-extensions

      # Generate extensions.json
      echo '${builtins.toJSON (map (ext: {
          inherit (ext) extensionId version;
          path = "${ext}/share/chrome-extensions";
          updateUrl = "file://${ext}/share/chrome-extensions/update.xml";
        })
        extensionDrvs)}' > $out/share/chrome-extensions/extensions.json
    '';
  };

  # Create wrapper script that sets up Chrome with extensions
  wrapper = writeShellScriptBin "chrome-with-extensions" ''
    #!${stdenv.shell}

    # Set up Chrome policies for extensions
    export CHROME_POLICIES="$HOME/.config/chrome-policies"
    mkdir -p "$CHROME_POLICIES/policies/managed"

    # Create extension policy
    ${jq}/bin/jq -n --arg extensions "$(cat ${env}/share/chrome-extensions/extensions.json)" '
    {
      "ExtensionSettings": ($extensions | fromjson | map({
        (.extensionId): {
          "installation_mode": "normal_installed",
          "update_url": .updateUrl
        }
      }) | add)
    }' > "$CHROME_POLICIES/policies/managed/extensions.json"

    # Launch Chrome with policy directory
    exec ${chromium}/bin/chromium \
      --enable-features=ExtensionsToolbarMenu \
      --load-extension=${lib.concatMapStringsSep "," (ext: "${ext}/share/chrome-extensions/unpacked") extensionDrvs} \
      --policy-directory="$CHROME_POLICIES" \
      "$@"
  '';
in {
  # The complete environment with Chrome and extensions
  environment = env;

  # The wrapper script to launch Chrome with extensions
  chrome = wrapper;
}
