# Nix helper scripts

All scripts are pure .nix expressions and can be evaluated with `nix eval --file <script>`.

- hosts.nix — list NixOS host names from the flake
- home-users.nix — list Home Manager user names from the flake
- eval-host.nix — get a host's toplevel drvPath; args: --argstr host <name>
- eval-home.nix — get a user's activationPackage drvPath; args: --argstr user <name>
- check-secrets.nix — per-host secrets presence (example_token.yaml)
- hosts-hw-config.nix — whether each host has a hardware-configuration.nix
 - host-users.nix — map of host -> list of normal users declared
 - inputs.nix — list flake inputs with basic metadata (rev, lastModified)
 - hosts-option.nix — query any host config option (function; see usage)
 - compare-hosts.nix — compare an option between two hosts (function; see usage)

Examples:

- nix eval --file scripts/hosts.nix
- nix eval --file scripts/eval-host.nix --argstr host laptop
- nix eval --file scripts/check-secrets.nix
 - nix eval --file scripts/host-users.nix
 
 Function-style helpers (import + args):
 
 - nix eval --impure --expr '(import ./scripts/hosts-option.nix { host = "desktop"; path = "networking.hostName"; })'
 - nix eval --impure --expr '(import ./scripts/compare-hosts.nix { a = "desktop"; b = "laptop"; path = "networking.hostName"; })'

Tip: add --raw for plain strings; drvPaths print fine without --raw.
