{ lib, stdenv, fetchurl, }:
stdenv.mkDerivation rec {
  pname = "assemblyai-cli";
  version = "1.18.1";

  src = fetchurl {
    url =
      "https://github.com/AssemblyAI/assemblyai-cli/releases/download/v${version}/assemblyai_${version}_linux_amd64.tar.gz";
    sha256 = "sha256-veLKiXT8RJ+XzowiCr+y05eQvHyhBiZ6JgwJ2/i+0yA=";
  };

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/{bin,share/doc/${pname}}
    install -Dm755 assemblyai $out/bin/assemblyai
    install -Dm644 LICENSE $out/share/doc/${pname}/LICENSE
    install -Dm644 README.md $out/share/doc/${pname}/README.md
  '';

  meta = with lib; {
    description = "CLI for the AssemblyAI API";
    homepage = "https://github.com/AssemblyAI/assemblyai-cli";
    license = licenses.asl20;
    maintainers = [ ]; # Add maintainers if known
    platforms = platforms.linux;
    mainProgram = "assemblyai";
  };
}
