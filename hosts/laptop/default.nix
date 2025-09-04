{
  config,
  pkgs,
  lib,
  modulesPath,
  inputs,
  username,
  ...
}: {
  imports = let
    hasHW = builtins.pathExists (./. + "/hardware-configuration.nix");
  in
    lib.optional hasHW (./. + "/hardware-configuration.nix")
    ++ [
      (modulesPath + "/installer/scan/not-detected.nix")
      ../shared/base.nix
      ../../home/profiles/user.nix
      ../../home/profiles/laptop/laptop.nix
      ./display.nix
    ];

  networking.hostName = "laptop";

  # Laptop display is configured in ./display.nix

  # Use power-profiles-daemon for GNOME integration and avoid TLP conflicts
  powerManagement.powertop.enable = true;
  services = {
    tlp.enable = false; # disable TLP because GNOME prefers power-profiles-daemon
    "power-profiles-daemon".enable = true;
    # Enable fingerprint daemon and PAM fingerprint authentication on this laptop
    fprintd.enable = true;
  };
  # Force using fingerprint auth for console login and sudo via PAM on this host
  security.pam.services.login.fprintAuth = lib.mkForce true;
  security.pam.services.sudo.fprintAuth = lib.mkForce true;

  # Avoid bootloader installation in environments without EFI/boot partition
  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    efi.canTouchEfiVariables = lib.mkForce false;
    grub = {
      enable = lib.mkDefault true;
      devices = ["nodev"];
    };
  };

  fileSystems = lib.mkIf (!builtins.pathExists (./. + "/hardware-configuration.nix")) {
    "/" = {
      device = "nodev";
      fsType = "tmpfs";
      options = ["mode=0755" "size=2G"];
    };
  };
  swapDevices = lib.mkIf (!builtins.pathExists (./. + "/hardware-configuration.nix")) [];
}
