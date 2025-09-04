{
  config,
  lib,
  pkgs,
  ...
}: {
  # Provide a simple GNOME Wayland session with VM guest integrations.
  # This brings dynamic resolution and clipboard integration across common hypervisors.
  services = {
    # For GNOME: GDM with Wayland tends to handle dynamic resizes best inside VMs
    xserver = {
      enable = true;
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
      desktopManager.gnome.enable = true;

      # Try to cover most virtual GPUs. GNOME/Wayland often ignores this, but Xorg fallbacks use it.
      videoDrivers = [
        "qxl" # QEMU/Spice legacy
        "virtio" # QEMU virtio-gpu
        "vmware" # VMware SVGA
        "vesa"
      ];
    };

    # QEMU/Spice agent for dynamic resizing + clipboard + file transfers
    spice-vdagentd.enable = true;

    # VMware tools are configured under `virtualisation.vmware.guest` below
  };

  # VirtualBox guest services (auto-resize, clipboard, shared folders)
  virtualisation.virtualbox.guest.enable = true;
  virtualisation.vmware.guest.enable = true;

  # Extra packages that help inside VMs (optional)
  environment.systemPackages = with pkgs; [
    spice-vdagent
    open-vm-tools
  ];

  # Wayland sessions in VMs sometimes need udev/input tweaks; keep defaults for now

  # Audio via PipeWire
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
}
