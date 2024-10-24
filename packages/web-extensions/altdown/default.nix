# packages/web-extensions/altdown/default.nix
{
  lib,
  internal,
  nodejs,
}:
internal.webext-utils.buildChromeExtension {
  pname = "altdown";
  version = "1.0.0";
  src = ./.;

  # Optional: Override manifest values
  manifestOverrides = {
    description = "Enhanced alt text downloader extension";
    permissions = ["activeTab" "downloads"];
  };

  # Optional: Add build-time dependencies
  buildInputs = [nodejs];

  # Optional: Add post-patch modifications
  postPatch = ''
    # Example: Modify some source files if needed
    sed -i 's/DEBUG = true/DEBUG = false/' images.js
  '';

  meta = with lib; {
    description = "Alt text downloader extension";
    license = licenses.mit;
    maintainers = with maintainers; [bibi];
    platforms = platforms.all;
  };
}
