# Contributing

Thanks for your interest in improving this Nix flake.

- Discuss substantial changes in an issue before opening a PR.
- Keep changes scoped and use the PR template.
- Do not commit secrets or private data. Store only encrypted files under `secrets/`.

## Development

- Optional: enable direnv for a ready dev shell (`direnv allow`).
- Format: `nix fmt`
- Quick checks:
  - `nix flake check`
  - `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`
  - `nix build .#homeConfigurations.<user>.activationPackage`

## Style
- Use Alejandra for Nix formatting.
- Prefer small, composable modules; use `lib.mk*` for overrides.

## CI
- CI runs format check, `nix flake check`, builds hosts/HM, and evaluates helper scripts.
- PRs must pass CI before review.

## Commits
- Prefer conventional titles: `feat:`, `fix:`, `docs:`, `ci:`, `chore:`.
- Reference issues (e.g., `Fixes #123`).

---

By contributing, you agree to follow the Code of Conduct.
