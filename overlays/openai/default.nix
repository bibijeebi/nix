{
  channels,
  inputs,
  lib,
  ...
}: final: prev: {
  python3Packages = prev.python3Packages.override {
    overrides = pfinal: pprev: {
      openai = pprev.openai.overrideAttrs (oldAttrs: {
        version = "1.52.0";
        src = prev.fetchFromGitHub {
          owner = "openai";
          repo = "openai-python";
          rev = "refs/tags/v1.52.0";
          hash = "sha256-5Km/9Eif7iLvIlAwvYZnGEZnIkjbMxLcPzHbkjEhTXQ="; # Replace with actual hash
        };
      });
    };
  };
}
