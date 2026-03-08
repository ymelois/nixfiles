# Rust

- When the project uses a Nix flake (flake.nix) to provide the Rust toolchain, always use `cargo fmt` without `+nightly`. The toolchain channel is managed by the devShell, so `cargo +nightly fmt` will fail.
