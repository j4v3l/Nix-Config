# Security Policy

## Supported

- The `main` branch is supported. This is a configuration repo; releases are not versioned.

## Reporting a Vulnerability

- Please create a private security advisory or email the maintainer. Do not open a public issue for sensitive reports.
- Include reproduction steps and affected hosts/users where possible.

## Secrets and Credentials

- Do not commit plaintext secrets. Use sops-nix managed encrypted files under `secrets/`.
- CI does not decrypt secrets; keep private keys off CI.
