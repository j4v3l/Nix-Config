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
      ../../home/profiles/vm/vm.nix
    ];

  networking.hostName = "vm";

  # VM friendly: no heavy desktop by default; leave X disabled
  services = {
    qemuGuest.enable = lib.mkDefault true;
  };

  # Avoid bootloader installation in ephemeral/no-EFI VM environments
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
