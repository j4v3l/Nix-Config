# sops-nix + Home Manager

This repo integrates [sops-nix](https://github.com/Mic92/sops-nix) with Home Manager for per-user secrets.

## Setup

1) Choose an identity method:

   a) SSH-based (recommended): ensure you have an SSH key at ~/.ssh/id_ed25519
      The repo is configured with `sops.age.sshKeyPaths = [ ~/.ssh/id_ed25519 ]`.

   b) Dedicated age key:
      age-keygen -o ~/.config/sops/age/keys.txt
      grep -m1 '^# public key:' ~/.config/sops/age/keys.txt | sed 's/# public key: //' 

3) Create an encrypted secret (host-specific):

   mkdir -p secrets/{desktop,laptop,vm}
   sops --age <age-public-key> -e -i secrets/<host>/example_token.yaml
   # then open it and add your data, e.g.:
   # example_token: "abcdef"

4) The host HM module will pick it up automatically if the file exists:
   - desktop: home/profiles/desktop/desktop.nix
   - laptop:  home/profiles/laptop/laptop.nix
   - vm:      home/profiles/vm/vm.nix
   (We guard with pathExists to avoid eval failures.)

5) Apply your configuration:

   home-manager switch --flake .#<yourUser>

## Notes
- Decryption happens at activation time; keep encrypted files (YAML/JSON/Binary) under `secrets/` in git, never commit decrypted output.
- For multiple users/hosts, you can add multiple recipients and/or use host-specific sops files (e.g., `secrets/<host>/...`).
- If using SSH keys as age identities, see the sops-nix README for `sops.age.sshKeyPaths`.

## CI considerations

- The provided CI only evaluates whether expected secret files exist via `scripts/check-secrets.nix`; it does not decrypt them.
- Do not add AGE private keys or SSH private keys as CI secrets. Keep decryption local.
- If you need to gate builds when a required secret is missing, make `check-secrets.nix` fail on missing files and call it in CI as a required step.
