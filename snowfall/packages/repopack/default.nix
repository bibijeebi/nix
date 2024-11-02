{ lib, fetchFromGitHub, buildNpmPackage, }:

buildNpmPackage rec {
  pname = "repopack";
  version = "0.1.43";

  src = fetchFromGitHub {
    owner = "yamadashy";
    repo = "repopack";
    rev = "v${version}";
    hash = "sha256-OqVkOI6HqmW7Doaapc34CK6X1WfFHFtX/Et3WjCEp/w=";
  };

  npmDepsHash = "sha256-I6kJPVN/src0Bndb6oBwEdbKFVlFuUMDXaXOusvcBsE=";

  npmInstallFlags = [ "--ignore-scripts" ];

  meta = {
    description =
      "Repopack is a powerful tool that packs your entire repository into a single, AI-friendly file. Perfect for when you need to feed your codebase to Large Language Models (LLMs) or other AI tools like Claude, ChatGPT, and Gemini";
    homepage = "https://github.com/yamadashy/repopack";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bibi ];
    mainProgram = "repopack";
    platforms = lib.platforms.all;
  };
}
