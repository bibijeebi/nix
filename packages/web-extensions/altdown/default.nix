{
  lib,
  webext-utils,
}:
webext-utils.buildChromeExtension {
  name = "altdown";
  version = "1.0.0"; # Match this with your manifest.json version
  extensionId = lib.fakeSha256;

  # Since files are in the same directory, use ./.
  src = ./.;

  # If you need any build steps, add them here
  buildPhase = ''
    # If you need to compile/build anything
    # Otherwise you can omit this
  '';

  # Metadata for better package management
  meta = with lib; {
    description = "Alt text downloader extension";
    homepage = "https://github.com/yourusername/altdown"; # If you have one
    license = licenses.mit; # Or whatever license you're using
    maintainers = with maintainers; [bibi]; # Your maintainer name
    platforms = platforms.all;
  };
}
