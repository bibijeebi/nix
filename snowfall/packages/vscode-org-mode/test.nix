{
  stdenv,
  fetchFromGitHub,
  nodejs,
  vsce,
  lib,
  callPackage,
}: let
  nodeDependencies = (callPackage ./node2nix/ {}).nodeDependencies;
in
  stdenv.mkDerivation {
    name = "vscode-org-mode";
    version = "575a84f1e70b1326a865a60267a3551dcf11eebe";

    src = fetchFromGitHub {
      owner = "bibijeebi";
      repo = "vscode-org-mode";
      rev = "575a84f1e70b1326a865a60267a3551dcf11eebe";
      sha256 = "sha256-8gOTtXFd51LczSoX/wtUUfUcLz3N0VemrsS/NmJWoqg=";
    };

    buildInputs = [nodejs vsce];

    buildPhase = ''
      ln -s ${nodeDependencies}/lib/node_modules ./node_modules
      export PATH="${nodeDependencies}/bin:$PATH"

      vsce package
    '';

    installPhase = ''
      mkdir -p $out/share/vscode/extensions
      cp -r . $out/share/vscode/extensions/org-mode
    '';

    meta = with lib; {
      description = "Org-mode for VSCode";
      homepage = "https://github.com/bibijeebi/vscode-org-mode";
      license = licenses.mit;
    };
  }
