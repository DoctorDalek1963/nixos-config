{
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
  pname = "transmission-ntfy";
  version = "0.1.0";

  cargoPatches = [
    ./Cargo.lock.patch
    ./ntfy-tags.patch
  ];

  src = fetchFromGitHub {
    owner = "cartoush";
    repo = "transmission_to_push";
    rev = "9ebf0957e579da686be1a2395304f1fee1ca26b5";
    hash = "sha256-QolhzXE2WtILqkR6Fb3K9hwN5IHKuVA5MACZg4VOvek=";
  };

  cargoHash = "sha256-I1KeXTeRO5IrSghsnfkOeiyjpqtABfNhBeDydv5EApc=";
}
