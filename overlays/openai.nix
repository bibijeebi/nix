{ openai, fetchFromGitHub }:
openai.overrideAttrs (oldAttrs: {
  version = "1.52.0";
  src = fetchFromGitHub {
    owner = "openai";
    repo = "openai-python";
    rev = "refs/tags/v1.52.0";
    hash = "sha256-5Km/9Eif7iLvIlAwvYZnGEZnIkjbMxLcPzHbkjEhTXQ=";
  };
})
