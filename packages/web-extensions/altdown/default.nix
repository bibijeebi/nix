# packages/web-extensions/altdown/default.nix
{
  lib,
  internal,
}:
internal.webext-utils.buildChromeExtension {
  pname = "altdown"; # Changed from name to pname for consistency
  name = "altdown"; # Still need name for the extension ID generation
  version = "1.0.0";
  src = ./.;

  # Optional: Override manifest values
  manifestOverrides = {
    description = "Alt text downloader extension";
    permissions = ["activeTab" "downloads"];
  };

  meta = with lib; {
    description = "Alt text downloader extension";
    license = licenses.mit;
    maintainers = with maintainers; [bibi];
    platforms = platforms.all;
  };
}
