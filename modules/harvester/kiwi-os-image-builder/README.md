# How to use the certified openSUSE Leap 15.6 image for harvester-cloud

This document describes how to build an openSUSE Leap 15.6 image, which will be maintained over time, to be used as the operating system image for virtual machines hosting Harvester nested VMs.

## First of all, what is KIWI?

KIWI is an openSUSE tool for building Linux system images like ISO or QCOW2. It uses a declarative XML description to define the OS, packages, and configuration, producing reproducible images.

## `appliance.kiwi` File Overview

```console
<?xml version="1.0" encoding="utf-8"?>
<image schemaversion="7.5" name="opensuse-leap-15-6-harv-cloud-image">
    <description type="system">
        <author>harvester-cloud maintainers</author>
        <contact>none</contact>
        <specification>openSUSE Leap 15.6 image certified for harvester-cloud</specification>
    </description>
    <preferences>
        <version>1.15.3</version>
        <packagemanager>zypper</packagemanager>
        <locale>en_US</locale>
        <keytable>us</keytable>
        <timezone>UTC</timezone>
        <rpm-excludedocs>true</rpm-excludedocs>
        <rpm-check-signatures>false</rpm-check-signatures>
        <type image="iso" firmware="efi" kernelcmdline="console=ttyS0">
            <bootloader name="grub2" timeout="10"/>
        </type>
    </preferences>
    <repository type="rpm-md">
        <source path="obsrepositories:/"/>
    </repository>
    <packages type="image">
        <!-- Base system / Boot -->
        <package name="kernel-default"/>
        <package name="dracut-kiwi-live"/>
        <package name="grub2"/>
        <package name="grub2-i386-pc"/>
        <package name="grub2-x86_64-efi" arch="x86_64"/>
        <package name="grub2-branding-openSUSE"/>
        <package name="shim"/>
        <package name="dosfstools"/>
        <package name="systemd"/>
        <package name="timezone"/>
        <package name="udev"/>
        <package name="procps"/>
        <package name="filesystem"/>
        <!-- System utilities -->
        <package name="util-linux"/>
        <package name="tar"/>
        <package name="parted"/>
        <package name="less"/>
        <package name="bash-completion"/>
        <package name="which"/>
        <package name="iproute2"/>
        <package name="iputils"/>
        <package name="lvm2"/>
        <!-- Networking / KVM / Cloud -->
        <package name="libvirt"/>
        <package name="qemu-kvm"/>
        <package name="virt-install"/>
        <package name="openssh"/>
        <package name="cloud-init"/>
        <package name="python3-websockify"/>
        <package name="novnc"/>
        <package name="socat"/>
        <package name="sshpass"/>
        <!-- Services / Daemons -->
        <package name="nginx"/>
        <package name="chrony"/>
        <package name="cron"/>
        <package name="bind-utils"/>
        <!-- Extras / UI / Fonts -->
        <package name="plymouth"/>
        <package name="plymouth-theme-bgrt"/>
        <package name="fontconfig"/>
        <package name="fonts-config"/>
        <package name="vim"/>
        <package name="curl"/>
        <package name="patterns-openSUSE-base"/>
    </packages>
    <packages type="bootstrap">
        <package name="udev"/>
        <package name="filesystem"/>
        <package name="glibc-locale"/>
        <package name="cracklib-dict-full"/>
        <package name="ca-certificates"/>
        <package name="ca-certificates-mozilla"/>
        <package name="openSUSE-release"/>
        <package name="zypper"/>
    </packages>
</image>
```

- `<?xml version="1.0" encoding="utf-8"?>`
Declares the file as an XML document with UTF-8 encoding.
- `<image schemaversion="7.5" name="opensuse-leap-15-6-harv-cloud-image">`
Root element of the image description.
  - `schemaversion="7.5"` specifies the KIWI schema version.
  - `name` sets the internal name of the image.
- `<description type="system"> … </description>`
Provides metadata about the image:
  - `<author>`: Maintainers of the image (`harvester-cloud maintainers`).
  - `<contact>`: Contact information (set to `none`).
  - `<specification>`: Short description of the image (`openSUSE Leap 15.6 image certified for harvester-cloud`).
- `<preferences> … </preferences>`
Defines general build preferences and configuration:
  - `<version>`: KIWI version used (1.15.3).
  - `<packagemanager>`: Package manager to use (`zypper`).
  - `<locale>` and `<keytable>`: Language and keyboard settings (`en_US, us`).
  - `<timezone>`: System timezone (UTC).
  - `<rpm-excludedocs>`: Skip documentation files when installing RPMs (`true`).
  - `<rpm-check-signatures>`: Disable signature checks for RPMs (`false`).
  - `<type>`: Defines the output image type:
    - `image="iso"`: Build a bootable ISO image.
    - `firmware="efi"`: EFI boot enabled.
    - `kernelcmdline="console=ttyS0"`: Kernel parameter for serial console.
    - `<bootloader>`: Bootloader configuration (`grub2` with `10s` timeout).
- `<repository type="rpm-md"> … </repository>`
Package repository for building the image:
  - `<source path="obsrepositories:/"/>` points to the openSUSE Build Service repository.
- `<packages type="image"> … </packages>`
List of all packages installed in the ISO image:
  - Base system / Boot:
    - `kernel-default`, `dracut-kiwi-live`, `grub2`, `grub2-i386-pc`, `grub2-x86_64-efi`, `grub2-branding-openSUSE`, `shim`, `dosfstools`, `systemd`, `timezone`, `udev`, `procps`, `filesystem`.
  - System utilities:
    - `util-linux`, `tar`, `parted`, `less`, `bash-completion`, `which`, `iproute2`, `iputils`, `lvm2`.
  - Networking / KVM / Cloud:
    - `libvirt`, `qemu-kvm`, `virt-install`, `openssh`, `cloud-init`, `python3-websockify`, `novnc`, `socat`, `sshpass`.
  - Services / Daemons:
    - `nginx`, `chrony`, `cron`, `bind-utils`.
  - Extras / UI / Fonts:
    - `plymouth`, `plymouth-theme-bgrt`, `fontconfig`, `fonts-config`, `vim`, `curl`, `patterns-openSUSE-base`.
- `<packages type="bootstrap"> … </packages>`
Packages required for bootstrapping the build environment (minimal dependencies):
  - `udev`, `filesystem`, `glibc-locale`, `cracklib-dict-full`, `ca-certificates`, `ca-certificates-mozilla`, `openSUSE-release`, `zypper`.
- `</image>`
Closes the root element.
