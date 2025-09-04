{
  config,
  lib,
  pkgs,
  ...
}: {
  services = {
    xserver = {
      enable = true; # 25.05 GNOME
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
      desktopManager.gnome.enable = true;
    };
  };
}
