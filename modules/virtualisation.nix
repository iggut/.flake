{
  pkgs,
  config,
  lib,
  ...
}: {
  boot.extraModulePackages = with config.boot.kernelPackages; [
    kvmfr
  ];
  boot.extraModprobeConfig = ''
    options kvmfr static_size_mb=128
  '';

  users.groups.libvirtd.members = ["root" "iggut"];

  boot = {
    kernelModules = [
      "vfio_pci"
      "vfio_iommu_type1"
      "vfio"
      "kvmfr"
    ];

    kernelParams = [
      "intel_iommu=on"
      "nowatchdog"
      "preempt=voluntary"
      "iommu.passthrough=1"
      "iommu=pt"
      #"vfio-pci.ids=10de:2482,10de:228b"
      "kvm.ignore_msrs=1"
      "kvm.report_ignored_msrs=0"
      "split_lock_detect=off" # https://www.phoronix.com/news/Linux-Splitlock-Hurts-Gaming
    ];

    initrd.kernelModules = [
      "vfio_pci"
      "vfio_iommu_type1"
      "vfio"
    ];
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="vfio", OWNER="root", GROUP="libvirtd"
    SUBSYSTEM=="kvmfr", OWNER="root", GROUP="libvirtd", MODE="0660"
  '';

  environment.sessionVariables.LIBVIRT_DEFAULT_URI = ["qemu:///system"];
  environment.systemPackages = with pkgs; [
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
    gnome.adwaita-icon-theme
    docker-compose
    libvirt
    qemu_kvm
    distrobox # Wrapper around docker to create and start linux containers - Tool for creating and managing Linux containers using Docker
    virt-manager # Gui for QEMU/KVM Virtualisation - Graphical user interface for managing QEMU/KVM virtual machines
    linuxKernel.packages.linux_6_3.kvmfr
  ];

  virtualisation = {
    oci-containers.backend = "docker";
    docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
      listenOptions = [
        "/run/docker.sock"
      ];
    };
    libvirtd = {
      enable = true;
      onShutdown = "suspend";
      extraConfig = ''
        user="iggut"
      '';
      qemu = {
        package = pkgs.qemu_full;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [pkgs.OVMF.fd];
        verbatimConfig = ''
          namespaces = []
          user = "iggut"
          group = "libvirtd"
          nographics_allow_host_audio = 1
          cgroup_device_acl = [
            "/dev/null",
            "/dev/full",
            "/dev/zero",
            "/dev/random",
            "/dev/urandom",
            "/dev/ptmx",
          	"/dev/kvm",
            "/dev/kqemu",
            "/dev/rtc",
          	"/dev/hpet",
            "/dev/vfio/vfio",
            "/dev/kvmfr0",
          	"/dev/vfio/22",
            "/dev/shm/looking-glass"
          ]
        '';
      };
    };
    spiceUSBRedirection.enable = true;
    waydroid.enable = true;
  };

  services.spice-vdagentd.enable = true;

  fonts.fonts = [pkgs.dejavu_fonts]; # Need for looking-glass

  home-manager.users.iggut = {
    programs.looking-glass-client = {
      enable = true;
      settings = {
        #app.shmFile = "/dev/shm/looking-glass";
        app.allowDMA = true;
        app.shmFile = "/dev/kvmfr0";
        win.showFPS = true;
        spice.enable = true;
      };
    };
  };
}
