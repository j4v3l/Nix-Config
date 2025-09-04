# NixOS + Home Manager Flake

![CI](https://github.com/j4v3l/Nix-Config/actions/workflows/ci.yml/badge.svg)
![CI](https://github.com/j4v3l/Nix-Config/actions/workflows/update-flake.yml/badge.svg)
![GitHub Sponsors](https://img.shields.io/github/sponsors/j4v3l)

This repository provides a minimal flake to manage three hosts with NixOS 25.05 and Home Manager:
- Desktop
- Laptop
- VM

It also includes a standalone Home Manager configuration you can use on non-NixOS systems.

## Layout

- `flake.nix` — main entrypoint with NixOS configurations and Home Manager
- `hosts/` — per-host NixOS modules
  - `shared/base.nix` — common system settings
  - `desktop/`, `laptop/`, `vm/` — host-specific overrides
- `home/profiles/` — Home Manager modules
  - `common.nix` — reusable HM configuration for the user
  - `user.nix` — NixOS module that enables HM for the flake-provided username

Set your Linux username once in `flake.nix` (variable `username`). All modules read it via specialArgs; no profile hard-codes `vmware` anymore.

## Prerequisites

- NixOS 25.05 or later (for NixOS machines)
- Nix with flakes enabled (this flake sets the option in system config)

## First-time setup on a NixOS host

1) Clone this repo to the target machine, e.g. `/home/<user>/Nix-Config`.

2) Ensure your hardware config exists. During `nixos-install`, NixOS usually generates `/etc/nixos/hardware-configuration.nix`. You can import it into a host module if you want. This scaffold uses the generic `not-detected.nix` and works for many VMs and simple machines. For best results, add your real hardware config later.

3) Build and switch to a host configuration:

- Desktop
  nix build .#nixosConfigurations.desktop.config.system.build.toplevel
  sudo nixos-rebuild switch --flake .#desktop

- Laptop
  nix build .#nixosConfigurations.laptop.config.system.build.toplevel
  sudo nixos-rebuild switch --flake .#laptop

- VM
  nix build .#nixosConfigurations.vm.config.system.build.toplevel
  sudo nixos-rebuild switch --flake .#vm

`nixos-rebuild switch --flake .#<hostname>` is the main command you’ll use to apply changes.

## Using Home Manager only (non‑NixOS)

You can reuse `homeConfigurations` defined in the flake, for example on another Linux distro or macOS with nix installed:

- Build and activate your home environment:
  nix build .#homeConfigurations.<yourUser>.activationPackage
  home-manager switch --flake .#<yourUser>

If `home-manager` isn’t installed, you can run it through nix:

- One-off run via nix:
  nix run github:nix-community/home-manager -- switch --flake .#<yourUser>

## Common tasks

- Format Nix files:
  nix fmt

- Lint formatting in CI the same way:
  nix run nixpkgs#alejandra -- -c .

- Open a dev shell with tools like `git` and `alejandra`:
  nix develop

- Add a package to all systems: edit `hosts/shared/base.nix` (environment.systemPackages)
- Add a package to your user: edit `home/profiles/common.nix` (home.packages)

## Customizing

- Desktop environment: Desktop uses KDE Plasma 6; Laptop uses GNOME. Adjust in `hosts/<name>/default.nix`.
- Timezone and locale: change in `hosts/shared/base.nix`.
- Username: set the `username` variable in `flake.nix`.
- Bootloader: base defaults to systemd-boot on EFI. For legacy BIOS or custom layouts, modify `hosts/shared/base.nix`.

## Troubleshooting

- If `sudo: command not found`, ensure `security.sudo.enable = true;` (already enabled in shared base).
- If X won’t start on Desktop/Laptop, check your GPU drivers and consider adding hardware-specific modules.
- If `nix` says flakes are not enabled, they will be after you switch to this config. For one-time commands before switching, prefix with `nix --extra-experimental-features 'nix-command flakes' <cmd>`.

## CI

This repo ships a GitHub Actions workflow at `.github/workflows/ci.yml` that runs on pushes and PRs:

- Format check with Alejandra
- `nix flake check`
- Build all NixOS hosts: `desktop`, `laptop`, `vm`
- Build Home Manager activation for user(s) declared in `flake.nix` (default: `vmware`)

If you change the default username in `flake.nix`, update the `build-home` matrix in the workflow or refactor it to dynamically detect users (future improvement).

## License

MIT
