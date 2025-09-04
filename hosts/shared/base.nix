{
  config,
  pkgs,
  lib,
  username,
  ...
}: {
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    warn-dirty = false;
    auto-optimise-store = true;
  };

  time.timeZone = "UTC"; # change if needed
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # Enable basic services
  # Automatic system updates (unattended)
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "weekly";
  };

  # Automatic time sync
  services.timesyncd.enable = true;

  # Nix garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };
  services.openssh.enable = lib.mkDefault true;
  security.sudo.enable = true;
  security.polkit.enable = true;

  # Networking
  networking.networkmanager.enable = true;

  # Global packages
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
    htop
    nix-index
  ];

  # Keep login shell default to zsh at system level; per-user config lives in HM
  programs = {
    zsh.enable = true;
    # Allow running prebuilt dynamically linked binaries outside Nix by auto-providing libs
    nix-ld.enable = true;
    # Provide command-not-found database/system hook
    command-not-found.enable = true;
  };
  users.defaultUserShell = pkgs.zsh;

  # Prefer Wayland sessions where supported (GDM/SDDM decide session type)

  # Enable flakes-friendly channels
  nixpkgs.config.allowUnfree = true;

  # Enable firmware and microcode updates
  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = lib.mkDefault true;
    cpu.amd.updateMicrocode = lib.mkDefault true;
  };

  # Ensure primary user exists on all hosts
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    # No default password committed. Set a password via a private overlay or
    # manually with `passwd` after installation. For CI/eval safety, keep secrets out of git.
    # Example (private repo/overlay):
    # hashedPasswordFile = "/run/keys/${username}-passwd"; # provisioned out-of-band
  };

  # Bootloader (simple default; adjust for your system)
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  # Required: don’t change lightly after initial install
  system.stateVersion = "25.05";
}
