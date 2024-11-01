{ lib, stdenv, fetchFromGitHub, bash, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "alf";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "DannyBen";
    repo = "alf";
    rev = "v${version}";
    hash = "sha256-7JtTm0YzA9K19aq2yDeZ8pTSA222e8bLXhPH0e7ezFk=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm755 alf "$out/bin/alf"

    # Ensure bash 4.0+ is available
    wrapProgram "$out/bin/alf" \
      --prefix PATH : ${lib.makeBinPath [ bash ]}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Your Little Bash Alias Friend - A bash alias manager";
    longDescription = ''
      Alf enhances your bash alias management. It allows you to:
      - Create aliases using a config file
      - Create aliases for sub-commands (e.g., 'g s' for 'git status')
      - Synchronize aliases across hosts via GitHub
      - Works with bash and zsh
    '';
    homepage = "https://github.com/DannyBen/alf";
    changelog = "https://github.com/DannyBen/alf/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "alf";
    platforms = platforms.all;
  };
}
