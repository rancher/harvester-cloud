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

## `config.sh` File Overview

```console
#!/bin/bash
set -ex

systemctl enable sshd
systemctl enable libvirtd
systemctl enable cloud-init
systemctl enable cloud-init-local
systemctl enable cloud-config
systemctl enable cloud-final
```

- `#!/bin/bash`: Executes the script using Bash.
- `set -e`: Exit immediately if any command fails.
- `set -x`: Print each command before executing it (useful for debugging during the build).
- `systemctl enable sshd`: Enables the OpenSSH daemon to allow remote access to the VM after boot.
- `systemctl enable libvirtd`: Enables the libvirt daemon, required to run and manage KVM-based virtual machines (used by Harvester nested VMs).
- `systemctl enable cloud-init-local`: Early initialization stage, runs before networking is configured.
- `systemctl enable cloud-init`: Main cloud-init service responsible for instance initialization.
- `systemctl enable cloud-config`: Applies user and system configuration provided via cloud-init.
- `systemctl enable cloud-final`: Executes final cloud-init tasks once the system is fully up.

## How to create the image locally - for educational purposes only, as it is not possible to upload the image from here

```console
$ pwd
~/harvester-cloud/modules/harvester/kiwi-os-image-builder
$
```

```bash
docker run -it --rm --privileged --platform linux/amd64 -v $(pwd):/build opensuse/leap:15.6
zypper addrepo http://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/openSUSE_Leap_15.6 kiwi
zypper --gpg-auto-import-keys refresh
zypper in -y python311-kiwi git binutils qemu-tools squashfs xorriso dosfstools e2fsprogs
kiwi system build --description build/ --set-repo https://download.opensuse.org/distribution/leap/15.6/repo/oss --target-dir /tmp/kiwi-outputs/ && cp /tmp/kiwi-outputs/*.iso /build/
```

#### Example

```console
$ pwd
~/harvester-cloud/modules/harvester/kiwi-os-image-builder
$ ll
total 32
drwxr-xr-x  3 glovecchio  staff    96 Jan 26 11:51 root
-rw-r--r--  1 glovecchio  staff  3028 Jan 27 16:20 appliance.kiwi
-rw-r--r--  1 glovecchio  staff   190 Jan 27 17:05 config.sh
drwxr-xr-x  7 glovecchio  staff   224 Jan 27 18:35 ..
-rw-r--r--  1 glovecchio  staff  8018 Jan 28 13:09 README.md
drwxr-xr-x  6 glovecchio  staff   192 Jan 28 13:09 .
$ orb ps
To use Docker:
    docker run ...
See "orb docker" for more info.

To create a Linux machine:
    orb create ubuntu
See "orb create --help" for supported distros and options.
$ docker run -it --rm --privileged --platform linux/amd64 -v $(pwd):/build opensuse/leap:15.6
:/ # zypper addrepo http://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/openSUSE_Leap_15.6 kiwi
Adding repository 'kiwi' ............................................................................................................................[done]
Repository 'kiwi' successfully added

URI         : http://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/openSUSE_Leap_15.6
Enabled     : Yes
GPG Check   : Yes
Autorefresh : No
Priority    : 99 (default priority)

Repository priorities are without effect. All enabled repositories share the same priority.
:/ # zypper --gpg-auto-import-keys refresh
Looking for gpg keys in repository Update repository of openSUSE Backports.
  gpgkey=http://download.opensuse.org/update/leap/15.6/backports/repodata/repomd.xml.key
Retrieving repository 'Update repository of openSUSE Backports' metadata ............................................................................[done]
Building repository 'Update repository of openSUSE Backports' cache .................................................................................[done]
Looking for gpg keys in repository Update repository with updates from SUSE Linux Enterprise 15.
  gpgkey=http://download.opensuse.org/update/leap/15.6/sle/repodata/repomd.xml.key
Retrieving repository 'Update repository with updates from SUSE Linux Enterprise 15' metadata .......................................................[done]
Building repository 'Update repository with updates from SUSE Linux Enterprise 15' cache ............................................................[done]
Looking for gpg keys in repository Main Update Repository.
  gpgkey=http://download.opensuse.org/update/leap/15.6/oss/repodata/repomd.xml.key
Retrieving repository 'Main Update Repository' metadata .............................................................................................[done]
Building repository 'Main Update Repository' cache ..................................................................................................[done]
Looking for gpg keys in repository Update Repository (Non-Oss).
  gpgkey=http://download.opensuse.org/update/leap/15.6/non-oss/repodata/repomd.xml.key
Retrieving repository 'Update Repository (Non-Oss)' metadata ........................................................................................[done]
Building repository 'Update Repository (Non-Oss)' cache .............................................................................................[done]
Looking for gpg keys in repository kiwi.
  gpgkey=http://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/openSUSE_Leap_15.6/repodata/repomd.xml.key

Automatically importing the following key:

  Repository:       kiwi
  Key Fingerprint:  85E2 6470 357A 6391 DBA1 BC9E 0739 B802 7BF9 39EF
  Key Name:         Virtualization:Appliances OBS Project <Virtualization:Appliances@build.opensuse.org>
  Key Algorithm:    RSA 2048
  Key Created:      Thu Jul  4 18:20:32 2024
  Key Expires:      Sat Sep 12 18:20:32 2026
  Rpm Name:         gpg-pubkey-7bf939ef-6686e7f0



    Note: A GPG pubkey is clearly identified by its fingerprint. Do not rely on the key's name. If
    you are not sure whether the presented key is authentic, ask the repository provider or check
    their web site. Many providers maintain a web page showing the fingerprints of the GPG keys they
    are using.
Retrieving repository 'kiwi' metadata ...............................................................................................................[done]
Building repository 'kiwi' cache ....................................................................................................................[done]
Looking for gpg keys in repository Non-OSS Repository.
  gpgkey=http://download.opensuse.org/distribution/leap/15.6/repo/non-oss/repodata/repomd.xml.key
Retrieving repository 'Non-OSS Repository' metadata .................................................................................................[done]
Building repository 'Non-OSS Repository' cache ......................................................................................................[done]
Retrieving repository 'Open H.264 Codec (openSUSE Leap)' metadata ...................................................................................[done]
Building repository 'Open H.264 Codec (openSUSE Leap)' cache ........................................................................................[done]
Looking for gpg keys in repository Main Repository.
  gpgkey=http://download.opensuse.org/distribution/leap/15.6/repo/oss/repodata/repomd.xml.key
Retrieving repository 'Main Repository' metadata ....................................................................................................[done]
Building repository 'Main Repository' cache .........................................................................................................[done]
All repositories have been refreshed.
:/ # zypper in -y python311-kiwi git binutils qemu-tools squashfs xorriso dosfstools e2fsprogs
Loading repository data...
Reading installed packages...
Resolving package dependencies...

The following 78 NEW packages are going to be installed:
  binutils busybox busybox-less dosfstools e2fsprogs file git git-core glibc-locale-base kiwi-systemdeps-core libaio1 libburn4 libctf-nobfd0 libctf0
  libdevmapper1_03 libexpat1 libext2fs2 libgdbm4 libgmodule-2_0-0 libgnutls30 libhogweed6 libisoburn1 libisofs6 liblzo2-2 libmpath0 libnettle8 libnuma1
  libopenssl1_1 libpython3_11-1_0 libpython3_6m1_0 libseccomp2 libsepol1 libsha1detectcoll1 liburcu6 liburing2 libxkbcommon0 libxslt1 libyaml-0-2 lsof
  mtools openslp perl perl-Error perl-Git pkg-config python3-base python311 python311-PyYAML python311-apipkg python311-base python311-certifi
  python311-cffi python311-charset-normalizer python311-cryptography python311-cssselect python311-docopt python311-idna python311-iniconfig python311-kiwi
  python311-lxml python311-py python311-pyOpenSSL python311-pycparser python311-requests python311-simplejson python311-urllib3 python311-xmltodict
  qemu-img qemu-pr-helper qemu-tools rsync screen squashfs system-group-kvm tar virtiofsd xkeyboard-config xorriso

78 new packages to install.

Package download size:    66.2 MiB

Package install size change:
              |     306.8 MiB  required by packages that will be installed
   306.8 MiB  |  -      0 B    released by packages that will be removed

Backend:  classic_rpmtrans
Continue? [y/n/v/...? shows all options] (y): y
Retrieving: dosfstools-4.1-3.6.1.x86_64 (Main Repository)                                                                             (1/78),  71.4 KiB    
Retrieving: dosfstools-4.1-3.6.1.x86_64.rpm ............................................................................................[done (15.3 KiB/s)]
Retrieving: file-5.32-7.14.1.x86_64 (Main Repository)                                                                                 (2/78),  50.0 KiB    
Retrieving: file-5.32-7.14.1.x86_64.rpm .............................................................................................................[done]
Retrieving: libburn4-1.5.6-150600.1.6.x86_64 (Main Repository)                                                                        (3/78), 143.8 KiB    
Retrieving: libburn4-1.5.6-150600.1.6.x86_64.rpm ........................................................................................[done (1.1 KiB/s)]
Retrieving: libgdbm4-1.12-1.418.x86_64 (Main Repository)                                                                              (4/78),  76.5 KiB    
Retrieving: libgdbm4-1.12-1.418.x86_64.rpm ..........................................................................................................[done]
Retrieving: libisofs6-1.5.6-150600.1.5.x86_64 (Main Repository)                                                                       (5/78), 206.5 KiB    
Retrieving: libisofs6-1.5.6-150600.1.5.x86_64.rpm ...................................................................................................[done]
Retrieving: liblzo2-2-2.10-2.22.x86_64 (Main Repository)                                                                              (6/78),  50.8 KiB    
Retrieving: liblzo2-2-2.10-2.22.x86_64.rpm ..........................................................................................................[done]
Retrieving: libnuma1-2.0.14.20.g4ee5e0c-150400.1.24.x86_64 (Main Repository)                                                          (7/78),  31.8 KiB    
Retrieving: libnuma1-2.0.14.20.g4ee5e0c-150400.1.24.x86_64.rpm ......................................................................................[done]
Retrieving: libseccomp2-2.5.3-150400.2.4.x86_64 (Main Repository)                                                                     (8/78),  61.5 KiB    
Retrieving: libseccomp2-2.5.3-150400.2.4.x86_64.rpm .................................................................................................[done]
Retrieving: libsepol1-3.1-150400.1.70.x86_64 (Main Repository)                                                                        (9/78), 257.4 KiB    
Retrieving: libsepol1-3.1-150400.1.70.x86_64.rpm ....................................................................................................[done]
Retrieving: libsha1detectcoll1-1.0.3-2.18.x86_64 (Main Repository)                                                                   (10/78),  23.2 KiB    
Retrieving: libsha1detectcoll1-1.0.3-2.18.x86_64.rpm ................................................................................................[done]
Retrieving: liburcu6-0.12.1-1.30.x86_64 (Main Repository)                                                                            (11/78),  97.2 KiB    
Retrieving: liburcu6-0.12.1-1.30.x86_64.rpm .........................................................................................................[done]
Retrieving: liburing2-2.1-150400.2.4.x86_64 (Main Repository)                                                                        (12/78),  36.4 KiB    
Retrieving: liburing2-2.1-150400.2.4.x86_64.rpm .....................................................................................................[done]
Retrieving: lsof-4.99.0-150600.1.15.x86_64 (Main Repository)                                                                         (13/78), 324.0 KiB    
Retrieving: lsof-4.99.0-150600.1.15.x86_64.rpm .........................................................................................[done (45.1 KiB/s)]
Retrieving: openslp-2.0.0-150600.19.5.x86_64 (Main Repository)                                                                       (14/78),  65.3 KiB    
Retrieving: openslp-2.0.0-150600.19.5.x86_64.rpm ....................................................................................................[done]
Retrieving: system-group-kvm-20170617-150400.24.2.1.noarch (Main Repository)                                                         (15/78),  11.8 KiB    
Retrieving: system-group-kvm-20170617-150400.24.2.1.noarch.rpm ......................................................................................[done]
Retrieving: tar-1.34-150000.3.34.1.x86_64 (Main Repository)                                                                          (16/78), 250.4 KiB    
Retrieving: tar-1.34-150000.3.34.1.x86_64.rpm .........................................................................................[done (199.6 KiB/s)]
Retrieving: libisoburn1-1.5.6-150600.1.6.x86_64 (Main Repository)                                                                    (17/78), 388.9 KiB    
Retrieving: libisoburn1-1.5.6-150600.1.6.x86_64.rpm ....................................................................................[done (50.7 KiB/s)]
Retrieving: squashfs-4.6.1-150300.3.3.1.x86_64 (Main Repository)                                                                     (18/78), 212.6 KiB    
Retrieving: squashfs-4.6.1-150300.3.3.1.x86_64.rpm .....................................................................................[done (90.5 KiB/s)]
Retrieving: xorriso-1.5.6-150600.1.6.x86_64 (Main Repository)                                                                        (19/78), 349.3 KiB    
Retrieving: xorriso-1.5.6-150600.1.6.x86_64.rpm .....................................................................................................[done]
Retrieving: glibc-locale-base-2.38-150600.14.37.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)              (20/78),   1.4 MiB    
Retrieving: glibc-locale-base-2.38-150600.14.37.1.x86_64.rpm ..........................................................................[done (218.1 KiB/s)]
Retrieving: libaio1-0.3.113-150600.15.3.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                      (21/78),  21.3 KiB    
Retrieving: libaio1-0.3.113-150600.15.3.1.x86_64.rpm ....................................................................................[done (1.1 KiB/s)]
Retrieving: libctf-nobfd0-2.45-150100.7.57.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                   (22/78), 164.4 KiB    
Retrieving: libctf-nobfd0-2.45-150100.7.57.1.x86_64.rpm .............................................................................................[done]
Retrieving: libdevmapper1_03-2.03.22_1.02.196-150600.3.9.3.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)     (23/78), 190.5 KiB    
Retrieving: libdevmapper1_03-2.03.22_1.02.196-150600.3.9.3.x86_64.rpm ...............................................................................[done]
Retrieving: libexpat1-2.7.1-150400.3.31.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                      (24/78), 101.7 KiB    
Retrieving: libexpat1-2.7.1-150400.3.31.1.x86_64.rpm ................................................................................................[done]
Retrieving: libext2fs2-1.47.0-150600.4.6.2.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                     (25/78), 210.3 KiB    
Retrieving: libext2fs2-1.47.0-150600.4.6.2.x86_64.rpm ...............................................................................................[done]
Retrieving: libgmodule-2_0-0-2.78.6-150600.4.28.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)              (26/78), 147.9 KiB    
Retrieving: libgmodule-2_0-0-2.78.6-150600.4.28.1.x86_64.rpm ........................................................................................[done]
Retrieving: libnettle8-3.9.1-150600.3.2.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                      (27/78), 171.1 KiB    
Retrieving: libnettle8-3.9.1-150600.3.2.1.x86_64.rpm ................................................................................................[done]
Retrieving: libopenssl1_1-1.1.1w-150600.5.18.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                 (28/78),   1.4 MiB    
Retrieving: libopenssl1_1-1.1.1w-150600.5.18.1.x86_64.rpm ..............................................................................[done (60.7 KiB/s)]
Retrieving: libxslt1-1.1.34-150400.3.13.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                      (29/78), 145.6 KiB    
Retrieving: libxslt1-1.1.34-150400.3.13.1.x86_64.rpm ................................................................................................[done]
Retrieving: libyaml-0-2-0.1.7-150000.3.4.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                     (30/78),  50.2 KiB    
Retrieving: libyaml-0-2-0.1.7-150000.3.4.1.x86_64.rpm ...............................................................................................[done]
Retrieving: pkg-config-0.29.2-150600.15.6.3.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                    (31/78),  73.3 KiB    
Retrieving: pkg-config-0.29.2-150600.15.6.3.x86_64.rpm ..............................................................................................[done]
Retrieving: screen-4.6.2-150000.5.8.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                          (32/78), 531.9 KiB    
Retrieving: screen-4.6.2-150000.5.8.1.x86_64.rpm ......................................................................................[done (120.2 KiB/s)]
Retrieving: perl-5.26.1-150300.17.20.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                         (33/78),   6.5 MiB    
Retrieving: perl-5.26.1-150300.17.20.1.x86_64.rpm .......................................................................................[done (3.0 MiB/s)]
Retrieving: virtiofsd-1.10.1-150600.4.3.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                      (34/78), 880.5 KiB    
Retrieving: virtiofsd-1.10.1-150600.4.3.1.x86_64.rpm ...................................................................................[done (97.5 KiB/s)]
Retrieving: busybox-1.37.0-150500.10.14.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                      (35/78), 619.0 KiB    
Retrieving: busybox-1.37.0-150500.10.14.1.x86_64.rpm ................................................................................................[done]
Retrieving: rsync-3.2.7-150600.3.14.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                          (36/78), 441.5 KiB    
Retrieving: rsync-3.2.7-150600.3.14.1.x86_64.rpm ......................................................................................[done (416.6 KiB/s)]
Retrieving: libctf0-2.45-150100.7.57.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                         (37/78), 163.4 KiB    
Retrieving: libctf0-2.45-150100.7.57.1.x86_64.rpm ...................................................................................................[done]
Retrieving: binutils-2.45-150100.7.57.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                        (38/78),   6.4 MiB    
Retrieving: binutils-2.45-150100.7.57.1.x86_64.rpm ......................................................................................[done (6.4 MiB/s)]
Retrieving: libmpath0-0.9.8+247+suse.863ae86f-150600.3.6.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)     (39/78), 313.0 KiB    
Retrieving: libmpath0-0.9.8+247+suse.863ae86f-150600.3.6.1.x86_64.rpm ...................................................................[done (1.1 KiB/s)]
Retrieving: python311-base-3.11.14-150600.3.38.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)               (40/78),  11.0 MiB    
Retrieving: python311-base-3.11.14-150600.3.38.1.x86_64.rpm .............................................................................[done (9.4 MiB/s)]
Retrieving: libpython3_11-1_0-3.11.14-150600.3.38.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)            (41/78),   1.8 MiB    
Retrieving: libpython3_11-1_0-3.11.14-150600.3.38.1.x86_64.rpm .........................................................................[done (42.1 KiB/s)]
Retrieving: e2fsprogs-1.47.0-150600.4.6.2.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                      (42/78), 926.5 KiB    
Retrieving: e2fsprogs-1.47.0-150600.4.6.2.x86_64.rpm ..................................................................................[done (529.1 KiB/s)]
Retrieving: libhogweed6-3.9.1-150600.3.2.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                     (43/78), 226.0 KiB    
Retrieving: libhogweed6-3.9.1-150600.3.2.1.x86_64.rpm ...............................................................................................[done]
Retrieving: libpython3_6m1_0-3.6.15-150300.10.103.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)            (44/78),   1.2 MiB    
Retrieving: libpython3_6m1_0-3.6.15-150300.10.103.1.x86_64.rpm ........................................................................[done (147.2 KiB/s)]
Retrieving: python3-base-3.6.15-150300.10.103.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                (45/78),   7.8 MiB    
Retrieving: python3-base-3.6.15-150300.10.103.1.x86_64.rpm ..............................................................................[done (3.5 MiB/s)]
Retrieving: busybox-less-1.37.0-150500.7.9.1.noarch (Update repository with updates from SUSE Linux Enterprise 15)                   (46/78),  11.2 KiB    
Retrieving: busybox-less-1.37.0-150500.7.9.1.noarch.rpm .............................................................................................[done]
Retrieving: python311-3.11.14-150600.3.38.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                    (47/78), 287.7 KiB    
Retrieving: python311-3.11.14-150600.3.38.1.x86_64.rpm ..................................................................................[done (1.1 KiB/s)]
Retrieving: libgnutls30-3.8.3-150600.4.12.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                    (48/78), 912.7 KiB    
Retrieving: libgnutls30-3.8.3-150600.4.12.1.x86_64.rpm .................................................................................[done (77.7 KiB/s)]
Retrieving: git-core-2.51.0-150600.3.15.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                      (49/78),   6.0 MiB    
Retrieving: git-core-2.51.0-150600.3.15.1.x86_64.rpm ....................................................................................[done (5.9 MiB/s)]
Retrieving: python311-xmltodict-0.13.0-150600.3.7.2.noarch (Update repository with updates from SUSE Linux Enterprise 15)            (50/78),  28.1 KiB    
Retrieving: python311-xmltodict-0.13.0-150600.3.7.2.noarch.rpm .........................................................................[done (28.1 KiB/s)]
Retrieving: python311-simplejson-3.19.1-150400.6.10.2.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)          (51/78),  85.0 KiB    
Retrieving: python311-simplejson-3.19.1-150400.6.10.2.x86_64.rpm ....................................................................................[done]
Retrieving: python311-pycparser-2.21-150400.12.7.2.noarch (Update repository with updates from SUSE Linux Enterprise 15)             (52/78), 264.1 KiB    
Retrieving: python311-pycparser-2.21-150400.12.7.2.noarch.rpm .........................................................................[done (117.4 KiB/s)]
Retrieving: python311-iniconfig-2.0.0-150400.10.6.1.noarch (Update repository with updates from SUSE Linux Enterprise 15)            (53/78),  22.1 KiB    
Retrieving: python311-iniconfig-2.0.0-150400.10.6.1.noarch.rpm ......................................................................................[done]
Retrieving: python311-idna-3.4-150400.11.10.1.noarch (Update repository with updates from SUSE Linux Enterprise 15)                  (54/78),  95.9 KiB    
Retrieving: python311-idna-3.4-150400.11.10.1.noarch.rpm ............................................................................................[done]
Retrieving: python311-docopt-0.6.2-150600.18.5.2.noarch (Update repository with updates from SUSE Linux Enterprise 15)               (55/78),  40.6 KiB    
Retrieving: python311-docopt-0.6.2-150600.18.5.2.noarch.rpm .........................................................................................[done]
Retrieving: python311-cssselect-1.2.0-150400.12.6.2.noarch (Update repository with updates from SUSE Linux Enterprise 15)            (56/78),  56.6 KiB    
Retrieving: python311-cssselect-1.2.0-150400.12.6.2.noarch.rpm ......................................................................................[done]
Retrieving: python311-charset-normalizer-3.1.0-150400.9.7.2.noarch (Update repository with updates from SUSE Linux Enterprise 15)    (57/78), 105.4 KiB    
Retrieving: python311-charset-normalizer-3.1.0-150400.9.7.2.noarch.rpm ..............................................................................[done]
Retrieving: python311-certifi-2023.7.22-150400.12.6.2.noarch (Update repository with updates from SUSE Linux Enterprise 15)          (58/78),  21.2 KiB    
Retrieving: python311-certifi-2023.7.22-150400.12.6.2.noarch.rpm ....................................................................................[done]
Retrieving: python311-apipkg-3.0.1-150400.12.6.1.noarch (Update repository with updates from SUSE Linux Enterprise 15)               (59/78),  27.9 KiB    
Retrieving: python311-apipkg-3.0.1-150400.12.6.1.noarch.rpm .........................................................................................[done]
Retrieving: python311-PyYAML-6.0.2-150600.10.3.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)               (60/78), 209.7 KiB    
Retrieving: python311-PyYAML-6.0.2-150600.10.3.1.x86_64.rpm ............................................................................[done (40.8 KiB/s)]
Retrieving: qemu-pr-helper-8.2.10-150600.3.43.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                (61/78), 605.0 KiB    
Retrieving: qemu-pr-helper-8.2.10-150600.3.43.1.x86_64.rpm .............................................................................[done (60.7 KiB/s)]
Retrieving: qemu-img-8.2.10-150600.3.43.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                      (62/78),   2.1 MiB    
Retrieving: qemu-img-8.2.10-150600.3.43.1.x86_64.rpm ...................................................................................[done (90.5 KiB/s)]
Retrieving: python311-cffi-1.15.1-150400.8.7.2.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                 (63/78), 360.8 KiB    
Retrieving: python311-cffi-1.15.1-150400.8.7.2.x86_64.rpm ...........................................................................................[done]
Retrieving: python311-lxml-4.9.3-150400.8.8.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                  (64/78),   2.9 MiB    
Retrieving: python311-lxml-4.9.3-150400.8.8.1.x86_64.rpm ................................................................................[done (1.2 MiB/s)]
Retrieving: python311-py-1.11.0-150400.12.7.2.noarch (Update repository with updates from SUSE Linux Enterprise 15)                  (65/78), 172.0 KiB    
Retrieving: python311-py-1.11.0-150400.12.7.2.noarch.rpm ............................................................................................[done]
Retrieving: python311-cryptography-41.0.3-150600.23.6.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)        (66/78),   1.1 MiB    
Retrieving: python311-cryptography-41.0.3-150600.23.6.1.x86_64.rpm ....................................................................[done (147.2 KiB/s)]
Retrieving: python311-pyOpenSSL-23.2.0-150400.3.10.1.noarch (Update repository with updates from SUSE Linux Enterprise 15)           (67/78), 137.7 KiB    
Retrieving: python311-pyOpenSSL-23.2.0-150400.3.10.1.noarch.rpm .....................................................................................[done]
Retrieving: python311-urllib3-2.0.7-150400.7.24.1.noarch (Update repository with updates from SUSE Linux Enterprise 15)              (68/78), 277.7 KiB    
Retrieving: python311-urllib3-2.0.7-150400.7.24.1.noarch.rpm ...........................................................................[done (30.9 KiB/s)]
Retrieving: python311-requests-2.31.0-150400.6.18.1.noarch (Update repository with updates from SUSE Linux Enterprise 15)            (69/78), 173.6 KiB    
Retrieving: python311-requests-2.31.0-150400.6.18.1.noarch.rpm ......................................................................................[done]
Retrieving: mtools-4.0.43-150600.1.6.x86_64 (Main Repository)                                                                        (70/78), 223.7 KiB    
Retrieving: mtools-4.0.43-150600.1.6.x86_64.rpm .....................................................................................................[done]
Retrieving: xkeyboard-config-2.40-150600.1.2.noarch (Main Repository)                                                                (71/78), 430.9 KiB    
Retrieving: xkeyboard-config-2.40-150600.1.2.noarch.rpm ...............................................................................[done (175.7 KiB/s)]
Retrieving: perl-Error-0.17025-1.20.noarch (Main Repository)                                                                         (72/78),  40.5 KiB    
Retrieving: perl-Error-0.17025-1.20.noarch.rpm ......................................................................................................[done]
Retrieving: kiwi-systemdeps-core-10.2.38-lp156.2.1.x86_64 (kiwi)                                                                     (73/78), 990.1 KiB    
Retrieving: kiwi-systemdeps-core-10.2.38-lp156.2.1.x86_64.rpm ..................................................................................[not found]
Retrieving: kiwi-systemdeps-core-10.2.38-lp156.2.1.x86_64.rpm ..................................................................................[not found]
Retrieving: kiwi-systemdeps-core-10.2.38-lp156.2.1.x86_64.rpm .........................................................................[done (213.5 KiB/s)]
Retrieving: python311-kiwi-10.2.38-lp156.2.1.x86_64 (kiwi)                                                                           (74/78),   1.9 MiB    
Retrieving: python311-kiwi-10.2.38-lp156.2.1.x86_64.rpm ........................................................................................[not found]
Retrieving: python311-kiwi-10.2.38-lp156.2.1.x86_64.rpm ........................................................................................[not found]
Retrieving: python311-kiwi-10.2.38-lp156.2.1.x86_64.rpm ...............................................................................[done (702.9 KiB/s)]
Retrieving: libxkbcommon0-1.5.0-150600.3.3.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                   (75/78), 119.2 KiB    
Retrieving: libxkbcommon0-1.5.0-150600.3.3.1.x86_64.rpm .............................................................................................[done]
Retrieving: perl-Git-2.51.0-150600.3.15.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                      (76/78), 184.7 KiB    
Retrieving: perl-Git-2.51.0-150600.3.15.1.x86_64.rpm ................................................................................................[done]
Retrieving: qemu-tools-8.2.10-150600.3.43.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                    (77/78), 714.0 KiB    
Retrieving: qemu-tools-8.2.10-150600.3.43.1.x86_64.rpm .................................................................................[done (42.1 KiB/s)]
Retrieving: git-2.51.0-150600.3.15.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                           (78/78), 119.6 KiB    
Retrieving: git-2.51.0-150600.3.15.1.x86_64.rpm ........................................................................................[done (53.6 KiB/s)]

Checking for file conflicts: ........................................................................................................................[done]
( 1/78) Installing: dosfstools-4.1-3.6.1.x86_64 .....................................................................................................[done]
( 2/78) Installing: file-5.32-7.14.1.x86_64 .........................................................................................................[done]
( 3/78) Installing: libburn4-1.5.6-150600.1.6.x86_64 ................................................................................................[done]
( 4/78) Installing: libgdbm4-1.12-1.418.x86_64 ......................................................................................................[done]
( 5/78) Installing: libisofs6-1.5.6-150600.1.5.x86_64 ...............................................................................................[done]
( 6/78) Installing: liblzo2-2-2.10-2.22.x86_64 ......................................................................................................[done]
( 7/78) Installing: libnuma1-2.0.14.20.g4ee5e0c-150400.1.24.x86_64 ..................................................................................[done]
( 8/78) Installing: libseccomp2-2.5.3-150400.2.4.x86_64 .............................................................................................[done]
( 9/78) Installing: libsepol1-3.1-150400.1.70.x86_64 ................................................................................................[done]
(10/78) Installing: libsha1detectcoll1-1.0.3-2.18.x86_64 ............................................................................................[done]
(11/78) Installing: liburcu6-0.12.1-1.30.x86_64 .....................................................................................................[done]
(12/78) Installing: liburing2-2.1-150400.2.4.x86_64 .................................................................................................[done]
(13/78) Installing: lsof-4.99.0-150600.1.15.x86_64 ..................................................................................................[done]
(14/78) Installing: openslp-2.0.0-150600.19.5.x86_64 ................................................................................................[done]
/usr/sbin/groupadd -r -g 36 kvm
(15/78) Installing: system-group-kvm-20170617-150400.24.2.1.noarch ..................................................................................[done]
(16/78) Installing: tar-1.34-150000.3.34.1.x86_64 ...................................................................................................[done]
(17/78) Installing: libisoburn1-1.5.6-150600.1.6.x86_64 .............................................................................................[done]
(18/78) Installing: squashfs-4.6.1-150300.3.3.1.x86_64 ..............................................................................................[done]
(19/78) Installing: xorriso-1.5.6-150600.1.6.x86_64 .................................................................................................[done]
(20/78) Installing: glibc-locale-base-2.38-150600.14.37.1.x86_64 ....................................................................................[done]
(21/78) Installing: libaio1-0.3.113-150600.15.3.1.x86_64 ............................................................................................[done]
(22/78) Installing: libctf-nobfd0-2.45-150100.7.57.1.x86_64 .........................................................................................[done]
(23/78) Installing: libdevmapper1_03-2.03.22_1.02.196-150600.3.9.3.x86_64 ...........................................................................[done]
(24/78) Installing: libexpat1-2.7.1-150400.3.31.1.x86_64 ............................................................................................[done]
(25/78) Installing: libext2fs2-1.47.0-150600.4.6.2.x86_64 ...........................................................................................[done]
(26/78) Installing: libgmodule-2_0-0-2.78.6-150600.4.28.1.x86_64 ....................................................................................[done]
(27/78) Installing: libnettle8-3.9.1-150600.3.2.1.x86_64 ............................................................................................[done]
(28/78) Installing: libopenssl1_1-1.1.1w-150600.5.18.1.x86_64 .......................................................................................[done]
(29/78) Installing: libxslt1-1.1.34-150400.3.13.1.x86_64 ............................................................................................[done]
(30/78) Installing: libyaml-0-2-0.1.7-150000.3.4.1.x86_64 ...........................................................................................[done]
(31/78) Installing: pkg-config-0.29.2-150600.15.6.3.x86_64 ..........................................................................................[done]
(32/78) Installing: screen-4.6.2-150000.5.8.1.x86_64 ................................................................................................[done]
(33/78) Installing: perl-5.26.1-150300.17.20.1.x86_64 ...............................................................................................[done]
(34/78) Installing: virtiofsd-1.10.1-150600.4.3.1.x86_64 ............................................................................................[done]
(35/78) Installing: busybox-1.37.0-150500.10.14.1.x86_64 ............................................................................................[done]
(36/78) Installing: rsync-3.2.7-150600.3.14.1.x86_64 ................................................................................................[done]
(37/78) Installing: libctf0-2.45-150100.7.57.1.x86_64 ...............................................................................................[done]
update-alternatives: using /usr/bin/ld.bfd to provide /usr/bin/ld (ld) in auto mode
(38/78) Installing: binutils-2.45-150100.7.57.1.x86_64 ..............................................................................................[done]
(39/78) Installing: libmpath0-0.9.8+247+suse.863ae86f-150600.3.6.1.x86_64 ...........................................................................[done]
(40/78) Installing: python311-base-3.11.14-150600.3.38.1.x86_64 .....................................................................................[done]
(41/78) Installing: libpython3_11-1_0-3.11.14-150600.3.38.1.x86_64 ..................................................................................[done]
(42/78) Installing: e2fsprogs-1.47.0-150600.4.6.2.x86_64 ............................................................................................[done]
(43/78) Installing: libhogweed6-3.9.1-150600.3.2.1.x86_64 ...........................................................................................[done]
(44/78) Installing: libpython3_6m1_0-3.6.15-150300.10.103.1.x86_64 ..................................................................................[done]
(45/78) Installing: python3-base-3.6.15-150300.10.103.1.x86_64 ......................................................................................[done]
(46/78) Installing: busybox-less-1.37.0-150500.7.9.1.noarch .........................................................................................[done]
(47/78) Installing: python311-3.11.14-150600.3.38.1.x86_64 ..........................................................................................[done]
(48/78) Installing: libgnutls30-3.8.3-150600.4.12.1.x86_64 ..........................................................................................[done]
(49/78) Installing: git-core-2.51.0-150600.3.15.1.x86_64 ............................................................................................[done]
(50/78) Installing: python311-xmltodict-0.13.0-150600.3.7.2.noarch ..................................................................................[done]
(51/78) Installing: python311-simplejson-3.19.1-150400.6.10.2.x86_64 ................................................................................[done]
(52/78) Installing: python311-pycparser-2.21-150400.12.7.2.noarch ...................................................................................[done]
(53/78) Installing: python311-iniconfig-2.0.0-150400.10.6.1.noarch ..................................................................................[done]
(54/78) Installing: python311-idna-3.4-150400.11.10.1.noarch ........................................................................................[done]
(55/78) Installing: python311-docopt-0.6.2-150600.18.5.2.noarch .....................................................................................[done]
(56/78) Installing: python311-cssselect-1.2.0-150400.12.6.2.noarch ..................................................................................[done]
(57/78) Installing: python311-charset-normalizer-3.1.0-150400.9.7.2.noarch ..........................................................................[done]
(58/78) Installing: python311-certifi-2023.7.22-150400.12.6.2.noarch ................................................................................[done]
(59/78) Installing: python311-apipkg-3.0.1-150400.12.6.1.noarch .....................................................................................[done]
(60/78) Installing: python311-PyYAML-6.0.2-150600.10.3.1.x86_64 .....................................................................................[done]
(61/78) Installing: qemu-pr-helper-8.2.10-150600.3.43.1.x86_64 ......................................................................................[done]
(62/78) Installing: qemu-img-8.2.10-150600.3.43.1.x86_64 ............................................................................................[done]
(63/78) Installing: python311-cffi-1.15.1-150400.8.7.2.x86_64 .......................................................................................[done]
(64/78) Installing: python311-lxml-4.9.3-150400.8.8.1.x86_64 ........................................................................................[done]
(65/78) Installing: python311-py-1.11.0-150400.12.7.2.noarch ........................................................................................[done]
(66/78) Installing: python311-cryptography-41.0.3-150600.23.6.1.x86_64 ..............................................................................[done]
(67/78) Installing: python311-pyOpenSSL-23.2.0-150400.3.10.1.noarch .................................................................................[done]
(68/78) Installing: python311-urllib3-2.0.7-150400.7.24.1.noarch ....................................................................................[done]
(69/78) Installing: python311-requests-2.31.0-150400.6.18.1.noarch ..................................................................................[done]
(70/78) Installing: mtools-4.0.43-150600.1.6.x86_64 .................................................................................................[done]
(71/78) Installing: xkeyboard-config-2.40-150600.1.2.noarch .........................................................................................[done]
(72/78) Installing: perl-Error-0.17025-1.20.noarch ..................................................................................................[done]
(73/78) Installing: kiwi-systemdeps-core-10.2.38-lp156.2.1.x86_64 ...................................................................................[done]
(74/78) Installing: python311-kiwi-10.2.38-lp156.2.1.x86_64 .........................................................................................[done]
(75/78) Installing: libxkbcommon0-1.5.0-150600.3.3.1.x86_64 .........................................................................................[done]
(76/78) Installing: perl-Git-2.51.0-150600.3.15.1.x86_64 ............................................................................................[done]
(77/78) Installing: qemu-tools-8.2.10-150600.3.43.1.x86_64 ..........................................................................................[done]
(78/78) Installing: git-2.51.0-150600.3.15.1.x86_64 .................................................................................................[done]
Running post-transaction scripts ....................................................................................................................[done]
:/ # kiwi system build --description build/ --set-repo https://download.opensuse.org/distribution/leap/15.6/repo/oss --target-dir /tmp/kiwi-outputs/ && cp /tmp/kiwi-outputs/*.iso /build/
[ INFO    ]: 12:13:11 | Loading XML description: build/appliance.kiwi
[ INFO    ]: 12:13:11 | Support for XML markup available
[ INFO    ]: 12:13:11 | --> loaded build/appliance.kiwi
[ INFO    ]: 12:13:11 | --> Selected build type: iso
[ INFO    ]: 12:13:11 | Preparing new root system
[ INFO    ]: 12:13:11 | Setup root directory: /tmp/kiwi-outputs/build/image-root
[ INFO    ]: 12:13:12 | Setting up repository https://download.opensuse.org/distribution/leap/15.6/repo/oss
[ INFO    ]: 12:13:12 | --> Type: rpm-md
[ INFO    ]: 12:13:12 | --> Translated: https://download.opensuse.org/distribution/leap/15.6/repo/oss
[ INFO    ]: 12:13:12 | --> Alias: d5f44027708e437fbdeb3dfb21a022d2
[ INFO    ]: 12:13:12 | Using package manager backend: zypper
[ INFO    ]: 12:13:12 | Installing bootstrap packages
[ INFO    ]: 12:13:12 | --> collection type: onlyRequired
[ INFO    ]: 12:13:12 | --> package: ca-certificates
[ INFO    ]: 12:13:12 | --> package: ca-certificates-mozilla
[ INFO    ]: 12:13:12 | --> package: cracklib-dict-full
[ INFO    ]: 12:13:12 | --> package: filesystem
[ INFO    ]: 12:13:12 | --> package: glibc-locale
[ INFO    ]: 12:13:12 | --> package: openSUSE-release
[ INFO    ]: 12:13:12 | --> package: udev
[ INFO    ]: 12:13:12 | --> package: zypper
[ INFO    ]: Processing: [########################################] 100%
[ INFO    ]: 12:14:24 | Importing Image description to system tree
[ INFO    ]: 12:14:24 | --> Importing state XML description to /tmp/kiwi-outputs/build/image-root/image/config.xml
[ INFO    ]: 12:14:24 | --> Importing config.sh script to /tmp/kiwi-outputs/build/image-root/image/config.sh
[ INFO    ]: 12:14:24 | --> Importing script helper functions
[ INFO    ]: 12:14:24 | Installing system (chroot) for build type: iso
[ INFO    ]: 12:14:24 | --> collection type: onlyRequired
[ INFO    ]: 12:14:24 | --> package: bash-completion
[ INFO    ]: 12:14:24 | --> package: bind-utils
[ INFO    ]: 12:14:24 | --> package: chrony
[ INFO    ]: 12:14:24 | --> package: cloud-init
[ INFO    ]: 12:14:24 | --> package: cron
[ INFO    ]: 12:14:24 | --> package: curl
[ INFO    ]: 12:14:24 | --> package: dosfstools
[ INFO    ]: 12:14:24 | --> package: dracut-kiwi-live
[ INFO    ]: 12:14:24 | --> package: filesystem
[ INFO    ]: 12:14:24 | --> package: fontconfig
[ INFO    ]: 12:14:24 | --> package: fonts-config
[ INFO    ]: 12:14:24 | --> package: grub2
[ INFO    ]: 12:14:24 | --> package: grub2-branding-openSUSE
[ INFO    ]: 12:14:24 | --> package: grub2-i386-pc
[ INFO    ]: 12:14:24 | --> package: grub2-x86_64-efi
[ INFO    ]: 12:14:24 | --> package: iproute2
[ INFO    ]: 12:14:24 | --> package: iputils
[ INFO    ]: 12:14:24 | --> package: kernel-default
[ INFO    ]: 12:14:24 | --> package: less
[ INFO    ]: 12:14:24 | --> package: libvirt
[ INFO    ]: 12:14:24 | --> package: lvm2
[ INFO    ]: 12:14:24 | --> package: nginx
[ INFO    ]: 12:14:24 | --> package: novnc
[ INFO    ]: 12:14:24 | --> package: openssh
[ INFO    ]: 12:14:24 | --> package: parted
[ INFO    ]: 12:14:24 | --> package: patterns-openSUSE-base
[ INFO    ]: 12:14:24 | --> package: plymouth
[ INFO    ]: 12:14:24 | --> package: plymouth-theme-bgrt
[ INFO    ]: 12:14:24 | --> package: procps
[ INFO    ]: 12:14:24 | --> package: python3-websockify
[ INFO    ]: 12:14:24 | --> package: qemu-kvm
[ INFO    ]: 12:14:24 | --> package: shim
[ INFO    ]: 12:14:24 | --> package: socat
[ INFO    ]: 12:14:24 | --> package: sshpass
[ INFO    ]: 12:14:24 | --> package: systemd
[ INFO    ]: 12:14:24 | --> package: tar
[ INFO    ]: 12:14:24 | --> package: timezone
[ INFO    ]: 12:14:24 | --> package: udev
[ INFO    ]: 12:14:24 | --> package: util-linux
[ INFO    ]: 12:14:24 | --> package: vim
[ INFO    ]: 12:14:24 | --> package: virt-install
[ INFO    ]: 12:14:24 | --> package: which
[ INFO    ]: Processing: [########################################] 100%
[ INFO    ]: 12:17:35 | Copying user defined files to image tree
[ INFO    ]: 12:17:35 | Setting up keytable: us
[ INFO    ]: 12:17:35 | Setting up locale: en_US
[ INFO    ]: 12:17:35 | Setting up timezone: UTC
[ INFO    ]: 12:17:35 | Check/Fix File Permissions
[ INFO    ]: 12:17:35 | Calling config.sh script
[ INFO    ]: 12:17:36 | Using package manager backend: zypper
[ INFO    ]: 12:17:36 | Creating system image
[ INFO    ]: 12:17:37 | Using following live ISO metadata:
[ INFO    ]: 12:17:37 | --> Application id: 0x16ddda39
[ INFO    ]: 12:17:37 | --> Publisher: SUSE LINUX GmbH
[ INFO    ]: 12:17:37 | --> Volume id: CDROM
[ INFO    ]: 12:17:37 | Setting up live image bootloader configuration
[ INFO    ]: 12:17:37 | Creating grub2 bootloader images
[ INFO    ]: 12:17:37 | --> Creating identifier file 0x16ddda39
[ INFO    ]: 12:17:37 | --> Creating bios image
[ INFO    ]: 12:17:38 | --> Using prebuilt unsigned efi image: grub_loader_type(filename='/tmp/kiwi-outputs/build/image-root/usr/share/grub2/x86_64-efi/grub.efi', binaryname='grub.efi', targetname='bootx64.efi')
[ INFO    ]: 12:17:38 | --> Creating loopback config
[ WARNING ]: 12:17:38 | No explicit root= cmdline provided
[ WARNING ]: 12:17:38 | No explicit root= cmdline provided
[ INFO    ]: 12:17:38 | Writing grub2 defaults file
[ INFO    ]: 12:17:38 | --> GRUB_CMDLINE_LINUX_DEFAULT:"console=ttyS0"
[ INFO    ]: 12:17:38 | --> GRUB_GFXMODE:auto
[ INFO    ]: 12:17:38 | --> GRUB_TERMINAL_INPUT:"console"
[ INFO    ]: 12:17:38 | --> GRUB_TERMINAL_OUTPUT:"gfxterm"
[ INFO    ]: 12:17:38 | --> GRUB_TIMEOUT:10
[ INFO    ]: 12:17:38 | Writing sysconfig bootloader file
[ INFO    ]: 12:17:38 | --> DEFAULT_APPEND:"console=ttyS0 "
[ INFO    ]: 12:17:38 | --> FAILSAFE_APPEND:"console=ttyS0  ide=nodma apm=off noresume edd=off nomodeset 3 "
[ INFO    ]: 12:17:38 | --> LOADER_LOCATION:none
[ INFO    ]: 12:17:38 | --> LOADER_TYPE:grub2-efi
[ INFO    ]: 12:17:38 | --> SECURE_BOOT:no
[ INFO    ]: 12:17:38 | Creating grub2 live ISO config file from template
[ INFO    ]: 12:17:38 | --> Using standard boot template
[ INFO    ]: 12:17:38 | Writing KIWI template grub.cfg file
[ INFO    ]: 12:17:38 | Creating live ISO boot image
[ INFO    ]: 12:17:38 | Creating generic dracut initrd archive
[ INFO    ]: 12:18:06 | Setting up kernel file(s) and boot image in ISO boot layout
[ INFO    ]: 12:18:06 | Packing system into dracut live ISO type: overlay
[ INFO    ]: 12:18:07 | Using calculated size: 1761 MB
[ INFO    ]: 12:18:07 | --> Syncing data to ext4 root image
[ INFO    ]: 12:18:13 | umount FileSystemExt4 instance
[ INFO    ]: 12:18:14 | --> Creating squashfs container for root image
[ INFO    ]: 12:19:06 | Creating live ISO image
[ INFO    ]: 12:19:08 | Export rpm packages metadata
[ INFO    ]: 12:19:08 | Export rpm packages changelog metadata
[ INFO    ]: 12:19:09 | Export rpm verification metadata
[ INFO    ]: 12:19:27 | Result files:
[ INFO    ]: 12:19:27 | --> image_changes: /tmp/kiwi-outputs/opensuse-leap-15-6-harv-cloud-image.x86_64-1.15.3.changes
[ INFO    ]: 12:19:27 | --> image_packages: /tmp/kiwi-outputs/opensuse-leap-15-6-harv-cloud-image.x86_64-1.15.3.packages
[ INFO    ]: 12:19:27 | --> image_verified: /tmp/kiwi-outputs/opensuse-leap-15-6-harv-cloud-image.x86_64-1.15.3.verified
[ INFO    ]: 12:19:27 | --> live_image: /tmp/kiwi-outputs/opensuse-leap-15-6-harv-cloud-image.x86_64-1.15.3.iso
:/ # exit
exit
$ ll
total 907192
drwxr-xr-x  3 glovecchio  staff         96 Jan 26 11:51 root
-rw-r--r--  1 glovecchio  staff       3028 Jan 27 16:20 appliance.kiwi
-rw-r--r--  1 glovecchio  staff        190 Jan 27 17:05 config.sh
drwxr-xr-x  7 glovecchio  staff        224 Jan 27 18:35 ..
-rw-r--r--  1 glovecchio  staff       8018 Jan 28 13:09 README.md
drwxr-xr-x  7 glovecchio  staff        224 Jan 28 13:19 .
-rw-r--r--  1 glovecchio  staff  464463872 Jan 28 13:19 opensuse-leap-15-6-harv-cloud-image.x86_64-1.15.3.iso
$ du -hsx opensuse-leap-15-6-harv-cloud-image.x86_64-1.15.3.iso
443M	opensuse-leap-15-6-harv-cloud-image.x86_64-1.15.3.iso
$
```

**Convert ISO to RAW (.img)**

```console
$ ll
total 907192
drwxr-xr-x  3 glovecchio  staff         96 Jan 26 11:51 root
-rw-r--r--  1 glovecchio  staff       3028 Jan 27 16:20 appliance.kiwi
-rw-r--r--  1 glovecchio  staff        190 Jan 27 17:05 config.sh
drwxr-xr-x  7 glovecchio  staff        224 Jan 27 18:35 ..
-rw-r--r--  1 glovecchio  staff       8018 Jan 28 13:09 README.md
drwxr-xr-x  7 glovecchio  staff        224 Jan 28 13:19 .
-rw-r--r--  1 glovecchio  staff  464463872 Jan 28 13:19 opensuse-leap-15-6-harv-cloud-image.x86_64-1.15.3.iso
$ 
```

```bash
docker run -it --rm --privileged --platform linux/amd64 -v $(pwd):/build opensuse/leap:15.6
zypper in -y qemu-tools
qemu-img convert -O raw /build/opensuse-leap-15-6-harv-cloud-image.x86_64-1.15.3.iso /build/opensuse-leap-15-6-harv-cloud-image.x86_64-1.15.3.img
ls -l /build/
```

##### Example

```console
$ docker run -it --rm --privileged --platform linux/amd64 -v $(pwd):/build opensuse/leap:15.6
:/ # zypper in -y qemu-tools
Looking for gpg keys in repository Update repository of openSUSE Backports.
  gpgkey=http://download.opensuse.org/update/leap/15.6/backports/repodata/repomd.xml.key
Retrieving repository 'Update repository of openSUSE Backports' metadata ............................................................................[done]
Building repository 'Update repository of openSUSE Backports' cache .................................................................................[done]
Looking for gpg keys in repository Non-OSS Repository.
  gpgkey=http://download.opensuse.org/distribution/leap/15.6/repo/non-oss/repodata/repomd.xml.key
Retrieving repository 'Non-OSS Repository' metadata .................................................................................................[done]
Building repository 'Non-OSS Repository' cache ......................................................................................................[done]
Retrieving repository 'Open H.264 Codec (openSUSE Leap)' metadata ...................................................................................[done]
Building repository 'Open H.264 Codec (openSUSE Leap)' cache ........................................................................................[done]
Looking for gpg keys in repository Main Repository.
  gpgkey=http://download.opensuse.org/distribution/leap/15.6/repo/oss/repodata/repomd.xml.key
Retrieving repository 'Main Repository' metadata ....................................................................................................[done]
Building repository 'Main Repository' cache .........................................................................................................[done]
Looking for gpg keys in repository Update repository with updates from SUSE Linux Enterprise 15.
  gpgkey=http://download.opensuse.org/update/leap/15.6/sle/repodata/repomd.xml.key
Retrieving repository 'Update repository with updates from SUSE Linux Enterprise 15' metadata .......................................................[done]
Building repository 'Update repository with updates from SUSE Linux Enterprise 15' cache ............................................................[done]
Looking for gpg keys in repository Main Update Repository.
  gpgkey=http://download.opensuse.org/update/leap/15.6/oss/repodata/repomd.xml.key
Retrieving repository 'Main Update Repository' metadata .............................................................................................[done]
Building repository 'Main Update Repository' cache ..................................................................................................[done]
Looking for gpg keys in repository Update Repository (Non-Oss).
  gpgkey=http://download.opensuse.org/update/leap/15.6/non-oss/repodata/repomd.xml.key
Retrieving repository 'Update Repository (Non-Oss)' metadata ........................................................................................[done]
Building repository 'Update Repository (Non-Oss)' cache .............................................................................................[done]
Loading repository data...
Reading installed packages...
Resolving package dependencies...

The following 23 NEW packages are going to be installed:
  libaio1 libdevmapper1_03 libexpat1 libgmodule-2_0-0 libgnutls30 libhogweed6 libmpath0 libnettle8 libnuma1 libopenssl1_1 libpython3_6m1_0 libseccomp2
  liburcu6 liburing2 libxkbcommon0 pkg-config python3-base qemu-img qemu-pr-helper qemu-tools system-group-kvm virtiofsd xkeyboard-config

23 new packages to install.

Package download size:    17.5 MiB

Package install size change:
              |      63.0 MiB  required by packages that will be installed
    63.0 MiB  |  -      0 B    released by packages that will be removed

Backend:  classic_rpmtrans
Continue? [y/n/v/...? shows all options] (y): y
Retrieving: libnuma1-2.0.14.20.g4ee5e0c-150400.1.24.x86_64 (Main Repository)                                                          (1/23),  31.8 KiB    
Retrieving: libnuma1-2.0.14.20.g4ee5e0c-150400.1.24.x86_64.rpm .........................................................................[done (19.6 KiB/s)]
Retrieving: libseccomp2-2.5.3-150400.2.4.x86_64 (Main Repository)                                                                     (2/23),  61.5 KiB    
Retrieving: libseccomp2-2.5.3-150400.2.4.x86_64.rpm .................................................................................................[done]
Retrieving: liburcu6-0.12.1-1.30.x86_64 (Main Repository)                                                                             (3/23),  97.2 KiB    
Retrieving: liburcu6-0.12.1-1.30.x86_64.rpm .............................................................................................[done (1.1 KiB/s)]
Retrieving: liburing2-2.1-150400.2.4.x86_64 (Main Repository)                                                                         (4/23),  36.4 KiB    
Retrieving: liburing2-2.1-150400.2.4.x86_64.rpm .....................................................................................................[done]
Retrieving: system-group-kvm-20170617-150400.24.2.1.noarch (Main Repository)                                                          (5/23),  11.8 KiB    
Retrieving: system-group-kvm-20170617-150400.24.2.1.noarch.rpm ......................................................................................[done]
Retrieving: libaio1-0.3.113-150600.15.3.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                       (6/23),  21.3 KiB    
Retrieving: libaio1-0.3.113-150600.15.3.1.x86_64.rpm ................................................................................................[done]
Retrieving: libdevmapper1_03-2.03.22_1.02.196-150600.3.9.3.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)      (7/23), 190.5 KiB    
Retrieving: libdevmapper1_03-2.03.22_1.02.196-150600.3.9.3.x86_64.rpm ...............................................................................[done]
Retrieving: libexpat1-2.7.1-150400.3.31.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                       (8/23), 101.7 KiB    
Retrieving: libexpat1-2.7.1-150400.3.31.1.x86_64.rpm ................................................................................................[done]
Retrieving: libgmodule-2_0-0-2.78.6-150600.4.28.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)               (9/23), 147.9 KiB    
Retrieving: libgmodule-2_0-0-2.78.6-150600.4.28.1.x86_64.rpm ........................................................................................[done]
Retrieving: libnettle8-3.9.1-150600.3.2.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                      (10/23), 171.1 KiB    
Retrieving: libnettle8-3.9.1-150600.3.2.1.x86_64.rpm ................................................................................................[done]
Retrieving: libopenssl1_1-1.1.1w-150600.5.18.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                 (11/23),   1.4 MiB    
Retrieving: libopenssl1_1-1.1.1w-150600.5.18.1.x86_64.rpm ...............................................................................[done (1.3 MiB/s)]
Retrieving: pkg-config-0.29.2-150600.15.6.3.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                    (12/23),  73.3 KiB    
Retrieving: pkg-config-0.29.2-150600.15.6.3.x86_64.rpm ..............................................................................................[done]
Retrieving: virtiofsd-1.10.1-150600.4.3.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                      (13/23), 880.5 KiB    
Retrieving: virtiofsd-1.10.1-150600.4.3.1.x86_64.rpm ...................................................................................[done (49.3 KiB/s)]
Retrieving: libmpath0-0.9.8+247+suse.863ae86f-150600.3.6.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)     (14/23), 313.0 KiB    
Retrieving: libmpath0-0.9.8+247+suse.863ae86f-150600.3.6.1.x86_64.rpm ...............................................................................[done]
Retrieving: libhogweed6-3.9.1-150600.3.2.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                     (15/23), 226.0 KiB    
Retrieving: libhogweed6-3.9.1-150600.3.2.1.x86_64.rpm ...............................................................................................[done]
Retrieving: libpython3_6m1_0-3.6.15-150300.10.103.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)            (16/23),   1.2 MiB    
Retrieving: libpython3_6m1_0-3.6.15-150300.10.103.1.x86_64.rpm ......................................................................................[done]
Retrieving: python3-base-3.6.15-150300.10.103.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                (17/23),   7.8 MiB    
Retrieving: python3-base-3.6.15-150300.10.103.1.x86_64.rpm ..............................................................................[done (5.5 MiB/s)]
Retrieving: libgnutls30-3.8.3-150600.4.12.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                    (18/23), 912.7 KiB    
Retrieving: libgnutls30-3.8.3-150600.4.12.1.x86_64.rpm ..............................................................................................[done]
Retrieving: qemu-pr-helper-8.2.10-150600.3.43.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                (19/23), 605.0 KiB    
Retrieving: qemu-pr-helper-8.2.10-150600.3.43.1.x86_64.rpm ............................................................................[done (456.3 KiB/s)]
Retrieving: qemu-img-8.2.10-150600.3.43.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                      (20/23),   2.1 MiB    
Retrieving: qemu-img-8.2.10-150600.3.43.1.x86_64.rpm ..................................................................................[done (467.8 KiB/s)]
Retrieving: xkeyboard-config-2.40-150600.1.2.noarch (Main Repository)                                                                (21/23), 430.9 KiB    
Retrieving: xkeyboard-config-2.40-150600.1.2.noarch.rpm .............................................................................................[done]
Retrieving: libxkbcommon0-1.5.0-150600.3.3.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                   (22/23), 119.2 KiB    
Retrieving: libxkbcommon0-1.5.0-150600.3.3.1.x86_64.rpm .............................................................................................[done]
Retrieving: qemu-tools-8.2.10-150600.3.43.1.x86_64 (Update repository with updates from SUSE Linux Enterprise 15)                    (23/23), 714.0 KiB    
Retrieving: qemu-tools-8.2.10-150600.3.43.1.x86_64.rpm ..............................................................................................[done]

Checking for file conflicts: ........................................................................................................................[done]
( 1/23) Installing: libnuma1-2.0.14.20.g4ee5e0c-150400.1.24.x86_64 ..................................................................................[done]
( 2/23) Installing: libseccomp2-2.5.3-150400.2.4.x86_64 .............................................................................................[done]
( 3/23) Installing: liburcu6-0.12.1-1.30.x86_64 .....................................................................................................[done]
( 4/23) Installing: liburing2-2.1-150400.2.4.x86_64 .................................................................................................[done]
/usr/sbin/groupadd -r -g 36 kvm
( 5/23) Installing: system-group-kvm-20170617-150400.24.2.1.noarch ..................................................................................[done]
( 6/23) Installing: libaio1-0.3.113-150600.15.3.1.x86_64 ............................................................................................[done]
( 7/23) Installing: libdevmapper1_03-2.03.22_1.02.196-150600.3.9.3.x86_64 ...........................................................................[done]
( 8/23) Installing: libexpat1-2.7.1-150400.3.31.1.x86_64 ............................................................................................[done]
( 9/23) Installing: libgmodule-2_0-0-2.78.6-150600.4.28.1.x86_64 ....................................................................................[done]
(10/23) Installing: libnettle8-3.9.1-150600.3.2.1.x86_64 ............................................................................................[done]
(11/23) Installing: libopenssl1_1-1.1.1w-150600.5.18.1.x86_64 .......................................................................................[done]
(12/23) Installing: pkg-config-0.29.2-150600.15.6.3.x86_64 ..........................................................................................[done]
(13/23) Installing: virtiofsd-1.10.1-150600.4.3.1.x86_64 ............................................................................................[done]
(14/23) Installing: libmpath0-0.9.8+247+suse.863ae86f-150600.3.6.1.x86_64 ...........................................................................[done]
(15/23) Installing: libhogweed6-3.9.1-150600.3.2.1.x86_64 ...........................................................................................[done]
(16/23) Installing: libpython3_6m1_0-3.6.15-150300.10.103.1.x86_64 ..................................................................................[done]
(17/23) Installing: python3-base-3.6.15-150300.10.103.1.x86_64 ......................................................................................[done]
(18/23) Installing: libgnutls30-3.8.3-150600.4.12.1.x86_64 ..........................................................................................[done]
(19/23) Installing: qemu-pr-helper-8.2.10-150600.3.43.1.x86_64 ......................................................................................[done]
(20/23) Installing: qemu-img-8.2.10-150600.3.43.1.x86_64 ............................................................................................[done]
(21/23) Installing: xkeyboard-config-2.40-150600.1.2.noarch .........................................................................................[done]
(22/23) Installing: libxkbcommon0-1.5.0-150600.3.3.1.x86_64 .........................................................................................[done]
(23/23) Installing: qemu-tools-8.2.10-150600.3.43.1.x86_64 ..........................................................................................[done]
:/ # qemu-img convert -O raw /build/opensuse-leap-15-6-harv-cloud-image.x86_64-1.15.3.iso /build/opensuse-leap-15-6-harv-cloud-image.x86_64-1.15.3.img
:/ # ls -l /build/
total 889248
-rw-r--r-- 1 root root     61064 Jan 28 12:41 README.md
-rw-r--r-- 1 root root      3028 Jan 27 15:20 appliance.kiwi
-rw-r--r-- 1 root root       190 Jan 27 16:05 config.sh
-rw-r--r-- 1 root root 464463872 Jan 28 12:19 opensuse-leap-15-6-harv-cloud-image.x86_64-1.15.3.iso
-rw-r--r-- 1 root root 464463872 Jan 28 12:51 opensuse-leap-15-6-harv-cloud-image.x86_64-1.15.3.img
drwxr-xr-x 1 root root        96 Jan 26 10:51 root
:/ # exit
exit
$ ll
total 1778504
drwxr-xr-x  3 glovecchio  staff         96 Jan 26 11:51 root
-rw-r--r--  1 glovecchio  staff       3028 Jan 27 16:20 appliance.kiwi
-rw-r--r--  1 glovecchio  staff        190 Jan 27 17:05 config.sh
drwxr-xr-x  7 glovecchio  staff        224 Jan 27 18:35 ..
-rw-r--r--  1 glovecchio  staff  464463872 Jan 28 13:19 opensuse-leap-15-6-harv-cloud-image.x86_64-1.15.3.iso
-rw-r--r--  1 glovecchio  staff  464463872 Jan 28 13:51 opensuse-leap-15-6-harv-cloud-image.x86_64-1.15.3.img
-rw-r--r--  1 glovecchio  staff      61619 Jan 28 13:52 README.md
drwxr-xr-x  8 glovecchio  staff        256 Jan 28 13:52 .
$
```
