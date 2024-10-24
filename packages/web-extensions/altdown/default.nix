{
  lib,
  buildChromeExtension,
}:
buildChromeExtension {
  pname = "altdown";
  version = "1.0.0";
  src = ./.;

  meta = with lib; {
    description = "Alt text downloader extension";
    license = licenses.mit;
    maintainers = with maintainers; [bibi];
  };
}
