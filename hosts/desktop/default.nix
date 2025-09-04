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
      ../../home/profiles/desktop/desktop.nix
      ./display.nix
    ];

  networking.hostName = "desktop";

  # Desktop-specific display is configured in ./display.nix

  # Hardware and performance
  services = {
    "power-profiles-daemon".enable = true;
  };

  # Avoid bootloader installation in environments without EFI/boot partition
  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    efi.canTouchEfiVariables = lib.mkForce false;
    grub = {
      enable = lib.mkDefault true;
      devices = ["nodev"];
    };
  };

  # Minimal root FS for evaluation only if hardware-configuration.nix is absent.
  # Replace by importing your generated hardware-configuration.nix.
  fileSystems = lib.mkIf (!builtins.pathExists (./. + "/hardware-configuration.nix")) {
    "/" = {
      device = "nodev";
      fsType = "tmpfs";
      options = ["mode=0755" "size=2G"];
    };
  };
  swapDevices = lib.mkIf (!builtins.pathExists (./. + "/hardware-configuration.nix")) [];
}
