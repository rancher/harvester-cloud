#!/bin/bash

exec > >(sudo tee /var/log/harvester-install.log) 2>&1

set -euo pipefail

# Set SELinux to permissive permanently
sudo setenforce 0 2>/dev/null || true
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config 2>/dev/null || true

# Installation of pre-requisite packages
sudo zypper --non-interactive addrepo https://download.opensuse.org/repositories/network/SLE_15/network.repo || true
sudo zypper --non-interactive addrepo https://download.opensuse.org/repositories/openSUSE:Leap:15.0/standard/openSUSE:Leap:15.0.repo || true
sudo zypper --non-interactive --gpg-auto-import-keys refresh
sudo zypper --non-interactive install parted util-linux virt-install libvirt qemu-kvm python3-websockify novnc socat nginx sshpass chrony cron
sudo systemctl enable --now libvirtd
sudo mkdir -p /srv/www/harvester

# Configure Chrony for air-gapped setup (local NTP server)
if [ ${harvester_airgapped} == true ]; then
  sudo sed -i 's/^pool/#pool/' /etc/chrony.conf
  sudo sed -i 's/^server/#server/' /etc/chrony.conf
  sudo sed -i 's/^include/#include/' /etc/chrony.conf
  echo "local stratum 10" | sudo tee -a /etc/chrony.conf
  echo "allow 192.168.122.0/24" | sudo tee -a /etc/chrony.conf
  sudo systemctl restart chronyd
  sudo systemctl enable --now chronyd
fi

# Checksum definitions for configuration files (harvester-cloud templates)
export NGINX_CONF_SUM="99f56dd5381bfe7b75b6e80dd86d88e1c1d82af7f0830d3d48af1ed716524427"
export VLAN1_XML_SUM="c7fc0cd2d5a928f1fc8bfd39f6175d3ff5bbc87f2013ec5635940627999ca5a0"
export SOCAT_SERVICE_SUM="da8dff6d4ab189ad3d740f0153437ff220488d32b904ebcd8a7ef3ac706e57b5"
export RESTART_HARV_VM_SCRIPT_SUM="18d6fdd9ea5898b2025d37f7b8fe3ca568833747a8413108031612a7560b9b62"

# Harvester artifacts version and checksum definitions
# 1.4.0
HARVESTER_1_4_0_VMLINUZ_SUM_amd64="ec76548b47fe75a4f3cff8061b04eac1bf45f77823ff1b96822f5afa3e7a6901e56d3548d4b859c70f7da4b8036dc6fa4e7417545f633e5e3dbf09e26e923f3a"
HARVESTER_1_4_0_INITRD_SUM_amd64="a009f21de7c9e7640d5b58a1339eb55a5aafc9d06f7554066608d36c15407077e6900825c7468952c0269bc4dd25bd3758b5afd2f287f92396b267ff23f9f411"
HARVESTER_1_4_0_ROOTFS_SUM_amd64="12145d8ab3257bdc85db2ecee66da93d058769bc9c0be8af2d0586391eb8e69d112c8d9e0e4050433f4a31edf08ca1dd92ef55cfc10ffa9d0feae40c086536f4"
HARVESTER_1_4_0_ISO_SUM_amd64="f076630dee44dcf7105ff3bf5f98d671d42d474228007f6133c12d3795c3c747a34eb8f3bb9f18f58e6083fcc1df3bcf2b25da1a117d59657c746fda4f2df085"
# 1.4.1
export HARVESTER_1_4_1_VMLINUZ_SUM_amd64="4ca4a8f8106f736a92e11ae56aa91ad1d1e511b510be6dbecf2b784683ac795b26c701aaa1498e8350f6601c9a8c818bc25b143992aa1e3886109c4496e173e0"
export HARVESTER_1_4_1_INITRD_SUM_amd64="b1ce39cd270dabbda3e49fe5b343e8eb32c4aadba76ea543e61f9388417866aec372d9e30133ae05a3ed2a4229b6d710cb8cf23f179072f873eb8ed7895ad0a1"
export HARVESTER_1_4_1_ROOTFS_SUM_amd64="f80e11f63798fb38430bbb90961c5d1f937b2bec1d83c068be4de4e3571a612bd16dcce92295d6cc431c0cf11d6d1a672dfbe8340d3414da9f11d45e96f1ae0e"
export HARVESTER_1_4_1_ISO_SUM_amd64="d736eb28b5859a722836549e800ec9d19ea535b6c531dcb70a2722f9a1c5c25434c2e3784141154e3a520c6501505444897c67b5be00edcf356f842d983e9209"
# 1.4.2
export HARVESTER_1_4_2_VMLINUZ_SUM_amd64="5d512a8359ddc45e057bcd4c2c60c3043f452779f316ac5d5fbd2050e4baf329337e1f20c899e2969596bbccc458ffd7e75914acfd820dc64ccc2e83c7b1307d"
export HARVESTER_1_4_2_INITRD_SUM_amd64="772ca208564388f8dd2de876dfccfb998196284cbabe8bda31ef8326b41dec7ad2aef605013de0d5a4edf848569f16eb5da13254bdfa75355b416ab0d40f2df4"
export HARVESTER_1_4_2_ROOTFS_SUM_amd64="21515863ecda6cc3e4ba890725101fb651261ea3268f2bfba7274efaf17bcb8a127e15d87a3bd5a0f0010db9b547f91103c231491790c61f32b0cce45e244546"
export HARVESTER_1_4_2_ISO_SUM_amd64="594557279012d3c5144a636ddb04cb864021e4bee8b0cc9bcda2a6192bd20e3799589f2bc643e4a27f28c6b3143e020fce2d565c657af37c3fa4aa4be59eb3c4"
# 1.4.3
export HARVESTER_1_4_3_VMLINUZ_SUM_amd64="91e662adfe93b6f9fa427e4b56972c72df8bdb211f9bb90199799454f566052b47cc31075ab64a2fc00f07faeb689856e91c3090430dfc862a363215921e1e16"
export HARVESTER_1_4_3_INITRD_SUM_amd64="8fd9ce996dae3be4f581dbf092e467c85881cf4fb315f1285aed755ab558e007e89a85cdebaaa576f89c022b863ba20c12d2604de5499c85196c9d11e15d0d29"
export HARVESTER_1_4_3_ROOTFS_SUM_amd64="4128ae7017d42caca992c6047c7f8b1caa0603cff00c3d0a4d88e1492f9bd2651f7ef205f892fc434a5ca7260e7611cd79430c1ec5db5156c99d3bf908988638"
export HARVESTER_1_4_3_ISO_SUM_amd64="4eff72da72d036c5c5c94660e64ae880639c9fe376141b5175c99c863593f6bd0b3a336e298e29990fcd84db505d9e655d4f2eacb634ed11efc081d0c1aa6057"
# 1.5.0
export HARVESTER_1_5_0_VMLINUZ_SUM_amd64="401dae4392e26cd28aea2b70f128064955ca3bea1b69021eb012650970e7265a7ed91be54e5a9fef9ea90c1c7ba41908ea60003fea6fcbcebf94be92930bc8ab"
export HARVESTER_1_5_0_INITRD_SUM_amd64="c705a4fe324f29ba6eea0d00210ec7249bd4a35dcd388c3e2c641a19b7bdc7483c2293df498c1b01dca830fda0ef9f46358a4b9d6a08aaee680c6ee3660c878d"
export HARVESTER_1_5_0_ROOTFS_SUM_amd64="8aec24c599d4ffe9f6dfeb0d623a9a08fbb9b6e2ee6670363cc64184b59793a2fd62e64fd89fc98ca31e93fc6a9881d2b2a344b4d562769ce89f633e67f06660"
export HARVESTER_1_5_0_ISO_SUM_amd64="df28e9bf8dc561c5c26dee535046117906581296d633eb2988e4f68390a281b6856a5a0bd2e4b5b988c695a53d0fc86e4e3965f19957682b74317109b1d2fe32"
# 1.5.1
export HARVESTER_1_5_1_VMLINUZ_SUM_amd64="91e662adfe93b6f9fa427e4b56972c72df8bdb211f9bb90199799454f566052b47cc31075ab64a2fc00f07faeb689856e91c3090430dfc862a363215921e1e16"
export HARVESTER_1_5_1_INITRD_SUM_amd64="de88a9f8cc455e015b83cd248c6c6ac6b3eee69909c4c8bda4465241af38999c5bb553f1cbb7a596ec038c83b5cb9af7dbe0f083f459c78203b635e3c28a9a57"
export HARVESTER_1_5_1_ROOTFS_SUM_amd64="b982d5e6b6f9b9bca5f448e8fec41f4e4468435705b4b38eeb749008b93c103af55bc8f0df4059b243aab48d8588af0fc1d5e1ff49bbee98d474f4558e7d5216"
export HARVESTER_1_5_1_ISO_SUM_amd64="1257e74c2d21f3777028a5c6c82c6ce3899aba175ef51d9695b11eedc6b2302f4dec76d815ee753a17e57a1ab37177fe1d5ab23cc64ae9087ffaaa35eba4a0b6"
# 1.5.2
export HARVESTER_1_5_2_VMLINUZ_SUM_amd64="beb42707c4a86d41b8943bea264f2c4f0892ad47c894a6afebccb6e60141fc55fa182b4441b2178b25479b579ca5fe2459933f580e718b7d0969738257939cfd"
export HARVESTER_1_5_2_INITRD_SUM_amd64="cf78843f451c8fe67f16c3601c54b86f4e1a3b7141addbbd9ac02ab406bd0ba83fd0f67f4701ebc4da25050cf110b56056697deb53e3623b1fed1ca88575fb55"
export HARVESTER_1_5_2_ROOTFS_SUM_amd64="2a31faf626cdc01d8a7b3626abefadc2e8d7fb02702e3314a25ca4ef12d46bcc30f9600152df735eb829ca45fd3825c4ced9756c17e2ce9463201281ea1c1e83"
export HARVESTER_1_5_2_ISO_SUM_amd64="fe189148de9921b2d9c3966c8bf10d7dbb7a3acbdb26e4b1669cbf1cff5cf96bdd7821217f8e92d10f82aa948fe3a1411070bc6ea9bbbf1dfb5c1689896bca8e"
# 1.6.0
export HARVESTER_1_6_0_VMLINUZ_SUM_amd64="beb42707c4a86d41b8943bea264f2c4f0892ad47c894a6afebccb6e60141fc55fa182b4441b2178b25479b579ca5fe2459933f580e718b7d0969738257939cfd"
export HARVESTER_1_6_0_INITRD_SUM_amd64="97b0b8683d0c2cc7a6bbc4ff81d606a6b0642b0bf2532f72db331c8a754be55968495b31f9121e89766fb71f509abfa8ae504324659a1e4206ca28b19ef33caa"
export HARVESTER_1_6_0_ROOTFS_SUM_amd64="44b01d66947bf971c93a29098b1a9f385edc6b1b386433ba96ffba7102f17542200d11faa0eca34f0c69b0faae7bd4cb3e4adc3ca5d59b42f3cace0690913a62"
export HARVESTER_1_6_0_ISO_SUM_amd64="9ffee4d575a35426036a84d02e7753601a399c5d152c3907ccd8e7e4bdb22954ff0f4f78e56321cb2d9277c7eb2784b4fcafa3fb7abc59cbb26b3086166943dc"
# 1.6.1
export HARVESTER_1_6_1_VMLINUZ_SUM_amd64="2f0a4c77e5ff60728f822d40db88756ccceaf09ddeb3a80f3ebd68706b02e75cf32363185239e1fa3d212157e72d03c7545f4e67ffd20982c54352ccf7d81fa0"
export HARVESTER_1_6_1_INITRD_SUM_amd64="f817bb37537f44076d54e4484f47aeb2e7d4b0c584c3bc293c82f8f2e20cc3b10cb2bdb78ad43bb9ef555603b0286d1a34404ecacbaa1bf5152e828fb7cfa1c8"
export HARVESTER_1_6_1_ROOTFS_SUM_amd64="7d2ba73dde4a45f24c9ab92856665ffb1da85d4c1c5c41e7811978346f36f5359ec9224e01f3f55c0777578c46c368a50eb1bed41d2a58430d319c09f96874c7"
export HARVESTER_1_6_1_ISO_SUM_amd64="a7192f5d5e21517d03d5e5cffe162026d8cd0691038f4c0eae5dc50d7ef416c935b233fc8bdc3bc02dcc7efaee6277e51bc4331867f4d9061d9ee3960324d63a"
# 1.7.0
export HARVESTER_1_7_0_VMLINUZ_SUM_amd64="a915c40d06db0345d6a3016e21224534efc531e415d2e8f29f22d02624a4acc0100a1182c10ffca18cf9d54a9b2b91d37bbf9713c09673f89c0370362a076e2b"
export HARVESTER_1_7_0_INITRD_SUM_amd64="d517f090300f2ac4a9ccc25025a3eda7d422fc607b87b2509709d741284b7271ff5d0e382eff9e0c9ec0a62f1704d2166de99a9d8c56592af3681607127ac645"
export HARVESTER_1_7_0_ROOTFS_SUM_amd64="91e791153b2b70643ee8f3e3f2140bfead3a94907d413547f07b6ec821076fef1b93e30939f42066fd57a9afd1f0de4a2aaef8080a84ca3e9936371282add51f"
export HARVESTER_1_7_0_ISO_SUM_amd64="e052134cf66781f3724e6b0da223a2b418a05ba0e98b7ccd93396f1aec058d61657220f0f82a2948fd7a48a2ac5924d8d9159d2732a930a14a3e704c16c82078"
# 1.7.1
export HARVESTER_1_7_1_VMLINUZ_SUM_amd64="a915c40d06db0345d6a3016e21224534efc531e415d2e8f29f22d02624a4acc0100a1182c10ffca18cf9d54a9b2b91d37bbf9713c09673f89c0370362a076e2b"
export HARVESTER_1_7_1_INITRD_SUM_amd64="1a5d355e33078a91b4bfb90da6668e0e66eeeae75952141fa9ccb9fcdbbeb65f65f7fe0f681eed7352cebff02944baa14ef24e76c24d7996f05daeaf1a61e3d1"
export HARVESTER_1_7_1_ROOTFS_SUM_amd64="d0a5df0bbefdf1a4ace0812140a0fb3fa549f511a4b3104a3ae6eb6cdbf3509963d6351088345aeb10ba2e4a3218abf8d40911a4eb068d69554f55e5fc36b94f"
export HARVESTER_1_7_1_ISO_SUM_amd64="381e6c6d09f4d5d1cb1b3813c1ad5dd8064618e5e5400b36fc26f05cea1425dd87659f93b7f34cd303d13289da7b34c5aa63ec935a8922c0e17ff733100ab361"

# Download the files needed to start the nested VM
#sudo curl -L -o /etc/nginx/nginx.conf \
#    https://raw.githubusercontent.com/rancher/harvester-cloud/refs/heads/main/modules/harvester/deployment-script/nginx_conf.tpl
#echo "$${NGINX_CONF_SUM}  /etc/nginx/nginx.conf" | sha256sum -c -
#sudo curl -L -o /srv/www/harvester/vlan1.xml \
#    https://raw.githubusercontent.com/rancher/harvester-cloud/refs/heads/main/modules/harvester/deployment-script/qemu_vlan1_xml.tpl
#echo "$${VLAN1_XML_SUM}  /srv/www/harvester/vlan1.xml" | sha256sum -c -
#sudo curl -L -o /etc/systemd/system/socat-proxy.service \
#    https://raw.githubusercontent.com/rancher/harvester-cloud/refs/heads/main/modules/harvester/deployment-script/socat_proxy_service.tpl
#echo "$${SOCAT_SERVICE_SUM}  /etc/systemd/system/socat-proxy.service" | sha256sum -c -
#sudo curl -L -o /usr/local/bin/restart_harvester_vms_script.sh \
#    https://raw.githubusercontent.com/rancher/harvester-cloud/refs/heads/main/modules/harvester/deployment-script/restart_harvester_vms_script_sh.tpl
#echo "$${RESTART_HARV_VM_SCRIPT_SUM}  /usr/local/bin/restart_harvester_vms_script.sh" | sha256sum -c -
sudo curl -L -o /etc/nginx/nginx.conf \
    https://raw.githubusercontent.com/rancher/harvester-cloud/refs/heads/bug-fix%2Fissue-172/modules/harvester/deployment-script/nginx_conf.tpl
echo "$${NGINX_CONF_SUM}  /etc/nginx/nginx.conf" | sha256sum -c -
sudo curl -L -o /srv/www/harvester/vlan1.xml \
    https://raw.githubusercontent.com/rancher/harvester-cloud/refs/heads/bug-fix%2Fissue-172/modules/harvester/deployment-script/qemu_vlan1_xml.tpl
echo "$${VLAN1_XML_SUM}  /srv/www/harvester/vlan1.xml" | sha256sum -c -
sudo curl -L -o /etc/systemd/system/socat-proxy.service \
    https://raw.githubusercontent.com/rancher/harvester-cloud/refs/heads/bug-fix%2Fissue-172/modules/harvester/deployment-script/socat_proxy_service.tpl
echo "$${SOCAT_SERVICE_SUM}  /etc/systemd/system/socat-proxy.service" | sha256sum -c -
sudo curl -L -o /usr/local/bin/restart_harvester_vms_script.sh \
    https://raw.githubusercontent.com/rancher/harvester-cloud/refs/heads/bug-fix%2Fissue-172/modules/harvester/deployment-script/restart_harvester_vms_script_sh.tpl
echo "$${RESTART_HARV_VM_SCRIPT_SUM}  /usr/local/bin/restart_harvester_vms_script.sh" | sha256sum -c -
HARV_VERSION="${version}"
SAFE_VERSION="$${HARV_VERSION//./_}"
VAR_VMLINUZ="HARVESTER_$${SAFE_VERSION}_VMLINUZ_SUM_amd64"
VAR_INITRD="HARVESTER_$${SAFE_VERSION}_INITRD_SUM_amd64"
VAR_ROOTFS="HARVESTER_$${SAFE_VERSION}_ROOTFS_SUM_amd64"
VAR_ISO="HARVESTER_$${SAFE_VERSION}_ISO_SUM_amd64"
sudo curl -L -o /srv/www/harvester/harvester-${version}-vmlinuz-amd64 \
    https://github.com/harvester/harvester/releases/download/${version}/harvester-${version}-vmlinuz-amd64
echo "$${!VAR_VMLINUZ}  /srv/www/harvester/harvester-${version}-vmlinuz-amd64" | sha256sum -c -
sudo curl -L -o /srv/www/harvester/harvester-${version}-initrd-amd64 \
    https://github.com/harvester/harvester/releases/download/${version}/harvester-${version}-initrd-amd64
echo "$${!VAR_INITRD}  /srv/www/harvester/harvester-${version}-initrd-amd64" | sha256sum -c -
sudo curl -L -o /srv/www/harvester/harvester-${version}-rootfs-amd64.squashfs \
    https://releases.rancher.com/harvester/${version}/harvester-${version}-rootfs-amd64.squashfs
echo "$${!VAR_ROOTFS}  /srv/www/harvester/harvester-${version}-rootfs-amd64.squashfs" | sha256sum -c -
sudo curl -L -o /srv/www/harvester/harvester-${version}-amd64.iso \
    https://releases.rancher.com/harvester/${version}/harvester-${version}-amd64.iso
echo "$${!VAR_ISO}  /srv/www/harvester/harvester-${version}-amd64.iso" | sha256sum -c -
touch /tmp/harvester_download_done

# Disk partitioning
for i in $(seq 1 "${count}"); do
  if [[ "${disk_name}" == /dev/sd ]]; then
    disk="${disk_name}$(printf "\x$(printf %x $((${disk_structure} + i)))")"
    part="$${disk}1"
  elif [[ "${disk_name}" == /dev/nvme ]]; then
    disk="${disk_name}$${i}n1"
    part="$${disk}p1"
  else
    echo "Error: unsupported disk type $disk_name"
    exit 1
  fi
  if [ -b "$${disk}" ]; then
    echo "Partitioning and mounting disk $${disk} on /mnt/datadisk$i..."
    sudo parted --script "$${disk}" mklabel gpt
    sudo parted --script "$${disk}" mkpart primary ext4 0% 100%
    sudo mkfs.ext4 "$${part}"
    sudo mkdir -p "/mnt/datadisk$i"
    sudo mount "$${part}" "/mnt/datadisk$i"
    echo "$${part} /mnt/datadisk$i ext4 defaults 0 0" | sudo tee -a /etc/fstab
  else
    echo "Error: disk $${disk} does not exist."
    exit 1
  fi
done
echo "Configuration completed successfully for ${count} disks."
