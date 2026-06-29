# Nix

- Pick the formatter by this order: if the flake defines a `formatter` output, use `nix fmt`; otherwise default to `nixfmt-rfc-style` (`nix run nixpkgs#nixfmt-rfc-style -- .`). The exception is a repo already formatted with a different tool and no `formatter` output: match its existing style instead of reformatting, since `nixfmt-rfc-style`, `alejandra`, and `nixpkgs-fmt` produce incompatible output. Confirm a guessed formatter with `--check` (an already-formatted file exits 0) before writing.
- Run `nix flake check` only when the flake defines `checks`; without them it just re-evaluates standard outputs and can trigger slow builds. Prefer building the specific target you changed.
- Validate a change by building, not switching. NixOS: `nixos-rebuild build --flake .#<host>`. home-manager: `nix build .#homeConfigurations.<name>.activationPackage`. A successful build is the validation; report build errors verbatim.
- For a fast eval-only check without a full build, evaluate the derivation path, for example `nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath`.
- Never run `switch` yourself; it mutates the running system. Suggest the command with the `!` prefix so the user runs it in the session, and let them decide.
