# Harvester cluster deployment process

The deployment does not require manual activities, with the exception of the configuration of four or five variables necessary for the Cloud Provider setup (subscription ID, Region, etc.).

The following [diagram](../images/HIGH_LEVEL_DEPLOYMENT_SCHEMA.png) provides a high-level overview of the deployment process to help you understand the Terraform workflow.

However, it is interesting to know what happens behind the scenes.

## What happens when running Terraform files?

### PREMISE | High-level description of the steps in the Terraform *main.tf* file

1. Editing template configuration files.
2. Creating the VM (and all related resources) in the cloud <- Execution of the *sles_startup_script_sh* script to setup the VM itself.
3. Execution of the *harvester_startup_script_sh* script to start the nested VMs (Harvester nodes).

**The process is the same for all Cloud Providers.**

### 1_ Creation of the VM in the cloud

The process of managing the VM sizing and associated data disks is the only non-standard aspect. 

The logic is as follows:

- You can choose a "small" or "medium" Harvester cluster (`harvester_cluster_size` variable).
- You can select 1 or 3 data disks, where 1 indicates a single Harvester node, and 3 indicates an HA Harvester cluster (`harvester_node_count` variable).

The reason for this is that each data disk is associated with a nested VM, as if it were the VM's own disk.

![](../images/HARVESTER_DEPLOYMENT_PROCESS_1.png)

#### Architecture

##### Harvester HA

```console
     |→ Data Disk 1 → Harvester Node 1
VM --|→ Data Disk 2 → Harvester Node 2
     |→ Data Disk 3 → Harvester Node 3
```

##### Harvester Single-Node

```console
VM --|→ Data Disk 1 → Harvester Node 1
```

### 2_ VM Setup

The template files and the scripts within the [modules/harvester/deployment-script](../modules/harvester/deployment-script) directory are processed and executed to configure the system.

![](../images/HARVESTER_DEPLOYMENT_PROCESS_2.png)

Some of these need to be processed, so they are modified within the Terraform workflow and then moved to the VM, while others are standard files that are moved without being modified.

Template files that are modified (in the Terraform *main.tf* file):

- *sles_startup_script_sh.tpl*
- *default_ipxe.tpl*
- *create_cloud_config_yaml.tpl*
- *join_cloud_config_yaml.tpl*
- *harvester_startup_script_sh.tpl*

![](../images/HARVESTER_DEPLOYMENT_PROCESS_3.png)
![](../images/HARVESTER_DEPLOYMENT_PROCESS_4.png)
![](../images/HARVESTER_DEPLOYMENT_PROCESS_5.png)

Standard files that are copied as they are (from the *sles_startup_script_sh* script):

- *nginx_conf.tpl*
- *qemu_vlan1_xml.tpl*
- *restart_harvester_vms_script_sh.tpl*
- *socat_proxy_service.tpl*

![](../images/HARVESTER_DEPLOYMENT_PROCESS_6.png)

As anticipated in the introduction, the two main scripts that coordinate everything are: 

1. *[sles_startup_script_sh](../modules/harvester/deployment-script/sles_startup_script_sh.tpl)*
2. *[harvester_startup_script_sh](../modules/harvester/deployment-script/harvester_startup_script_sh.tpl)*

#### 2.1_ */srv/www/harvester/sles_startup_script_sh*

**All parameters written with the format `${...}` are replaced by the variables configured in the project.**

##### Main steps

1. Installation of pre-requisite packages

```console
exec > >(sudo tee /var/log/harvester-install.log) 2>&1

set -euo pipefail

# Set SELinux to permissive permanently
sudo setenforce 0 2>/dev/null || true
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config 2>/dev/null || true

# Libvirt service initialization and Harvester directory setup
sudo systemctl enable --now libvirtd
sudo mkdir -p /srv/www/harvester
```

2. Download the files needed to start the nested VM

```console
# Download the files needed to start the nested VM
sudo curl -L -o /etc/nginx/nginx.conf \
    https://raw.githubusercontent.com/rancher/harvester-cloud/refs/heads/main/modules/harvester/deployment-script/nginx_conf.tpl
echo "$${NGINX_CONF_SUM}  /etc/nginx/nginx.conf" | sha512sum -c -
sudo curl -L -o /srv/www/harvester/vlan1.xml \
    https://raw.githubusercontent.com/rancher/harvester-cloud/refs/heads/main/modules/harvester/deployment-script/qemu_vlan1_xml.tpl
echo "$${VLAN1_XML_SUM}  /srv/www/harvester/vlan1.xml" | sha512sum -c -
sudo curl -L -o /etc/systemd/system/socat-proxy.service \
    https://raw.githubusercontent.com/rancher/harvester-cloud/refs/heads/main/modules/harvester/deployment-script/socat_proxy_service.tpl
echo "$${SOCAT_SERVICE_SUM}  /etc/systemd/system/socat-proxy.service" | sha512sum -c -
sudo curl -L -o /usr/local/bin/restart_harvester_vms_script.sh \
    https://raw.githubusercontent.com/rancher/harvester-cloud/refs/heads/main/modules/harvester/deployment-script/restart_harvester_vms_script_sh.tpl
echo "$${RESTART_HARV_VM_SCRIPT_SUM}  /usr/local/bin/restart_harvester_vms_script.sh" | sha512sum -c -
HARV_VERSION="${version}"
SAFE_VERSION="$${HARV_VERSION//./_}"
VAR_VMLINUZ="HARVESTER_$${SAFE_VERSION}_VMLINUZ_SUM_amd64"
VAR_INITRD="HARVESTER_$${SAFE_VERSION}_INITRD_SUM_amd64"
VAR_ROOTFS="HARVESTER_$${SAFE_VERSION}_ROOTFS_SUM_amd64"
VAR_ISO="HARVESTER_$${SAFE_VERSION}_ISO_SUM_amd64"
sudo curl -L -o /srv/www/harvester/harvester-${version}-vmlinuz-amd64 \
    https://github.com/harvester/harvester/releases/download/${version}/harvester-${version}-vmlinuz-amd64
echo "$${!VAR_VMLINUZ}  /srv/www/harvester/harvester-${version}-vmlinuz-amd64" | sha512sum -c -
sudo curl -L -o /srv/www/harvester/harvester-${version}-initrd-amd64 \
    https://github.com/harvester/harvester/releases/download/${version}/harvester-${version}-initrd-amd64
echo "$${!VAR_INITRD}  /srv/www/harvester/harvester-${version}-initrd-amd64" | sha512sum -c -
sudo curl -L -o /srv/www/harvester/harvester-${version}-rootfs-amd64.squashfs \
    https://releases.rancher.com/harvester/${version}/harvester-${version}-rootfs-amd64.squashfs
echo "$${!VAR_ROOTFS}  /srv/www/harvester/harvester-${version}-rootfs-amd64.squashfs" | sha512sum -c -
sudo curl -L -o /srv/www/harvester/harvester-${version}-amd64.iso \
    https://releases.rancher.com/harvester/${version}/harvester-${version}-amd64.iso
echo "$${!VAR_ISO}  /srv/www/harvester/harvester-${version}-amd64.iso" | sha512sum -c -
touch /tmp/harvester_download_done
```

This portion of the script downloads Harvester boot and installation files, storing them in `/srv/www/harvester/`. A flag file (`/tmp/harvester_download_done`) marks completion.  

3. Disk partitioning

```console
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
```

The final part of the script partitions, formats, and mounts a specified number of disks (`${count}`), appending them to `/etc/fstab` for persistence. If a disk is missing, the script exits with an error.  

#### 2.2_ */srv/www/harvester/harvester_startup_script_sh*

##### Main steps

1. Starting the Virtual Network

```console
sudo virsh net-define /srv/www/harvester/vlan1.xml
sudo virsh net-start vlan1
sudo virsh net-autostart vlan1
```

In this section, the script defines, starts, and enables autostart for the `vlan1` virtual network using `virsh`. The file `/srv/www/harvester/vlan1.xml` was downloaded by the `sles_startup_script.sh` script.

###### */srv/www/harvester/vlan1.xml*

```console
<network xmlns:dnsmasq='http://libvirt.org/schemas/network/dnsmasq/1.0'>
  <name>vlan1</name>
  <bridge name="virbr1"/>
  <forward mode="nat"/>
  <ip address="192.168.122.1" netmask="255.255.255.0">
      <tftp root='/srv/www/harvester'/>
      <dhcp>
      <range start="192.168.122.2" end="192.168.122.254">
        <lease expiry='168' unit='hours'/>
      </range>
    </dhcp>
  </ip>
  <dnsmasq:options>
    <dnsmasq:option value='dhcp-match=set:is_ipxe,175'/>
    <dnsmasq:option value='dhcp-boot=tag:!is_ipxe,ipxe.efi'/>
    <dnsmasq:option value='dhcp-boot=tag:is_ipxe,http://192.168.122.1/default.ipxe'/>
  </dnsmasq:options>
</network>
```

2. HTTP server configuration

```console
sudo chown nobody:nobody -R /srv/www
sudo systemctl enable --now nginx
```

This is because it is necessary for the nested VM to be able to reach the Harvester files present in the VM itself (iPXE boot).
The file `/etc/nginx/nginx.conf` was downloaded by the `sles_startup_script.sh` script.

###### */etc/nginx/nginx.conf*

```console
events {
    worker_connections  1024;
    use epoll;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;
    sendfile        on;
    tcp_nopush     on;
    keepalive_timeout  65;
    gzip  on;
    server {
            listen 192.168.122.1:80 default_server;
            server_name _;
            root /srv/www/harvester;
            autoindex on;
    }
}
```

3. Creation of nested VMs

```console
# Creation of nested VMs
for i in $(seq 1 ${count}); do
  if [ $i == 1 ]; then
    sudo sed -i "s/${hostname}/${hostname}-$i/g" /srv/www/harvester/create_cloud_config.yaml
    sudo virt-install --name harvester-node-$i --memory ${memory} --vcpus ${cpu} --cpu host-passthrough --disk path=/mnt/datadisk$i/harvester-data.qcow2,size=${harvester_default_disk_size},bus=virtio,format=qcow2 --boot loader=/usr/share/qemu/ovmf-x86_64-code.bin,loader_ro=yes,loader_type=pflash,nvram_template=/usr/share/qemu/ovmf-x86_64-vars.bin --os-type linux --os-variant generic --network bridge=virbr1,model=virtio --graphics vnc,listen=0.0.0.0,password=yourpass,port=$((5900 + i)) --console pty,target_type=serial --pxe --autostart &
    sleep 45
  elif [ $i == 2 ]; then
    sudo sed -i "s/${hostname}/${hostname}-$i/g" /srv/www/harvester/join_cloud_config.yaml
    sudo sed -i "s/create_cloud_config.yaml/join_cloud_config.yaml/g" /srv/www/harvester/default.ipxe
    sudo virt-install --name harvester-node-$i --memory ${memory} --vcpus ${cpu} --cpu host-passthrough --disk path=/mnt/datadisk$i/harvester-data.qcow2,size=${harvester_default_disk_size},bus=virtio,format=qcow2 --boot loader=/usr/share/qemu/ovmf-x86_64-code.bin,loader_ro=yes,loader_type=pflash,nvram_template=/usr/share/qemu/ovmf-x86_64-vars.bin --os-type linux --os-variant generic --network bridge=virbr1,model=virtio --graphics vnc,listen=0.0.0.0,password=yourpass,port=$((5900 + i)) --console pty,target_type=serial --pxe --autostart &
    sleep 45
  else
    sudo cp /srv/www/harvester/join_cloud_config.yaml /srv/www/harvester/join_cloud_config_$((i - 1)).yaml
    sudo sed -i "s/  hostname:.*/  hostname: ${hostname}-$i/" /srv/www/harvester/join_cloud_config_$((i - 1)).yaml
    sudo sed -i "s|join_cloud_config[^ ]*\.yaml|join_cloud_config_$((i - 1)).yaml|" /srv/www/harvester/default.ipxe
    sudo virt-install --name harvester-node-$i --memory ${memory} --vcpus ${cpu} --cpu host-passthrough --disk path=/mnt/datadisk$i/harvester-data.qcow2,size=${harvester_default_disk_size},bus=virtio,format=qcow2 --boot loader=/usr/share/qemu/ovmf-x86_64-code.bin,loader_ro=yes,loader_type=pflash,nvram_template=/usr/share/qemu/ovmf-x86_64-vars.bin --os-type linux --os-variant generic --network bridge=virbr1,model=virtio --graphics vnc,listen=0.0.0.0,password=yourpass,port=$((5900 + i)) --console pty,target_type=serial --pxe --autostart &
    sleep 45
  fi
done
```

Here, the script installs multiple `harvester-node` nested Virtual Machines based on the specified count (`${count}`).  

- For the first node, it customizes the cloud configuration file (`create_cloud_config.yaml`) and starts the VM with PXE boot.

###### */srv/www/harvester/default.ipxe* example

```console
#!ipxe
dhcp
kernel ${base}/harvester-${version}-vmlinuz-amd64 \
    initrd=harvester-${version}-initrd-amd64 \
    ip=dhcp \
    console=tty1 \
    net.ifnames=1 \
    rd.cos.disable \
    rd.noverifyssl \
    root=live:${base}/harvester-${version}-rootfs-amd64.squashfs \
    harvester.install.config_url=${base}/create_cloud_config.yaml \
    harvester.install.skipchecks=true \
    harvester.install.automatic=true
initrd ${base}/harvester-${version}-initrd-amd64
boot
```

###### */srv/www/harvester/create_cloud_config.yaml* example

```console
#cloud-config
scheme_version: 1
token: ${token}
os:
  hostname: ${hostname}
  password: ${password}
  ntp_servers:
  %{ if harvester_airgapped }
    - 192.168.122.1
  %{ else }
    - 0.suse.pool.ntp.org
    - 1.suse.pool.ntp.org
  %{ endif }
install:
  mode: create
  management_interface:
    interfaces:
      - name: ens3
    default_route: true
    method: dhcp
    bond_options:
      mode: active-backup
      miimon: 100
  device: /dev/vda
  iso_url: http://192.168.122.1/harvester-${version}-amd64.iso
  tty: tty1,115200n8
  vip: 192.168.122.120
  vip_mode: static
%{ if cluster_registration_url != "" }
system_settings:
  cluster-registration-url: ${cluster_registration_url}
%{ endif }
```

- For the second node, it customizes the cloud configuration for joining the cloud and updates the default iPXE boot file.

###### */srv/www/harvester/default.ipxe* example

```console
#!ipxe
dhcp
kernel http://192.168.122.1/harvester-v1.4.1-vmlinuz-amd64 \
    initrd=harvester-v1.4.1-initrd-amd64 \
    ip=dhcp \
    console=tty1 \
    net.ifnames=1 \
    rd.cos.disable \
    rd.noverifyssl \
    root=live:http://192.168.122.1/harvester-v1.4.1-rootfs-amd64.squashfs \
    harvester.install.config_url=http://192.168.122.1/join_cloud_config.yaml \ # Here is the only change
    harvester.install.skipchecks=true \
    harvester.install.automatic=true
initrd http://192.168.122.1/harvester-v1.4.1-initrd-amd64
boot
```

###### */srv/www/harvester/join_cloud_config.yaml* example

```console
#cloud-config
scheme_version: 1
server_url: https://192.168.122.120:443
token: SecretToken.123
os:
  hostname: your-prefix-2
  password: SecretPassword.123
  ntp_servers:
  - 0.suse.pool.ntp.org
  - 1.suse.pool.ntp.org
install:
  mode: join
  management_interface:
    interfaces:
      - name: ens3
    default_route: true
    method: dhcp
    bond_options:
      mode: active-backup
      miimon: 100
  device: /dev/vda
  iso_url: http://192.168.122.1/harvester-v1.4.1-amd64.iso
  tty: tty1,115200n8
```

- For subsequent nodes, it copies and modifies the join configuration file for each node, adjusting the hostname and updating the iPXE file.

###### */srv/www/harvester/default.ipxe* example

```console
#!ipxe
dhcp
kernel http://192.168.122.1/harvester-v1.4.1-vmlinuz-amd64 \
    initrd=harvester-v1.4.1-initrd-amd64 \
    ip=dhcp \
    console=tty1 \
    net.ifnames=1 \
    rd.cos.disable \
    rd.noverifyssl \
    root=live:http://192.168.122.1/harvester-v1.4.1-rootfs-amd64.squashfs \
    harvester.install.config_url=http://192.168.122.1/join_cloud_config_2.yaml \ # Here is the only change
    harvester.install.skipchecks=true \
    harvester.install.automatic=true
initrd http://192.168.122.1/harvester-v1.4.1-initrd-amd64
boot
```

###### */srv/www/harvester/join_cloud_config_2.yaml* example

```console
#cloud-config
scheme_version: 1
server_url: https://192.168.122.120:443
token: SecretToken.123
os:
  hostname: your-prefix-3
  password: SecretPassword.123
  ntp_servers:
  - 0.suse.pool.ntp.org
  - 1.suse.pool.ntp.org
install:
  mode: join
  management_interface:
    interfaces:
      - name: ens3
    default_route: true
    method: dhcp
    bond_options:
      mode: active-backup
      miimon: 100
  device: /dev/vda
  iso_url: http://192.168.122.1/harvester-v1.4.1-amd64.iso
  tty: tty1,115200n8
```

Each VM is installed using `virt-install` with specific resources (memory, CPU, disk) and configured for autostart.  

4. Monitoring nested VM states and restarting them when all are 'shut off'

```console
sudo chmod +x  /usr/local/bin/restart_harvester_vms_script.sh
(sudo crontab -l 2>/dev/null; echo "*/2 * * * * /usr/local/bin/restart_harvester_vms_script.sh") | sudo crontab -
```

This portion of the script grants execution permissions to `restart_harvester_vms_script.sh` and schedules it to run every 2 minutes using `cron`.  

This is necessary because when the VMs reboot (for example during the Harvester installation), they do not get back up and running on their own.

###### */usr/local/bin/restart_harvester_vms_script.sh*

```console
#!/bin/bash

LOGFILE="/var/log/restart_harvester_vms_script.log"

# Restart nested VMs that for some reason are not running ('shut off' state)
virsh list --all | awk '$3 == "shut" {print $2}' | while read -r vm; do
    if [[ -n "$vm" ]]; then
        echo "$(date): Starting VM $vm" | tee -a "$LOGFILE"
        virsh start "$vm" >>"$LOGFILE" 2>&1
    fi
done
```

5. Expose the Harvester nested VM via the VM's public IP

```console
sudo chmod 755 /etc/systemd/system/socat-proxy.service
sudo systemctl daemon-reload
sudo systemctl enable --now socat-proxy.service
```

In this section, the script sets the correct permissions for `socat-proxy.service`, reloads the systemd daemon, and enables the service to start immediately.

The `socat-proxy.service` is a systemd service that creates a proxy for specific TCP ports. It listens on ports `443` and `6443` and forwards the traffic to the IP `192.168.122.120` on the same ports. The service is designed to always restart if it fails and runs as the `root` user.

###### */etc/systemd/system/socat-proxy.service*

```console
[Unit]
Description=Socat Service

[Service]
ExecStart=/bin/bash -c "/usr/bin/socat TCP-LISTEN:443,fork TCP:192.168.122.120:443 & /usr/bin/socat TCP-LISTEN:6443,fork TCP:192.168.122.120:6443 & wait"
Restart=always
User=root

[Install]
WantedBy=multi-user.target
```

6. Wait for the Harvester services to start

```console
attempts=0
while [ "$attempts" -lt 15 ]; do
  ip=${public_ip}
  response=$(curl -k -s "https://$ip/ping")
  if [ "$response" == "pong" ]; then
    echo "Waiting for https://$ip/ping - response: $response"
    ((attempts++))
  else
    echo "Waiting for https://$ip/ping - response is not 'pong', retrying in 2 seconds..."
  fi
  sleep 2
done
```

7. Copying the KUBECONFIG file from the RKE2 cluster under the hood of Harvester

```console
sudo sshpass -p "${password}" ssh -oStrictHostKeyChecking=no "rancher@192.168.122.120" "sudo cat /etc/rancher/rke2/rke2.yaml" > /tmp/rke2.yaml
sudo sed -i "/certificate-authority-data:/c\\    insecure-skip-tls-verify: true" /tmp/rke2.yaml
```

8. Creating additional disks if `data_disk_count` variable is > 1

```console
# Creating additional disks if `data_disk_count` variable is > 1
if [ ${data_disk_count} -gt 1 ]; then
  disk_index=$(( ${count} + 1 ))  # Start indexing additional disks after the default disk
  for i in $(seq 1 ${count}); do
    for j in $(seq 1 $((${data_disk_count} - 1))); do
      # Create a new raw disk for each additional disk
      disk_path="/mnt/datadisk$disk_index/harvester-data.raw"
      sudo qemu-img create -f raw "$disk_path" ${harvester_default_disk_size}G

      # Generate a unique WWN for each disk
      wwn="0x5000c50015$(date +%N | sha512sum | head -c 6)"
      target_letter=$(echo $((disk_index + 1)) | awk '{printf "%c", 96 + $1}')
      target_dev="sd$target_letter"

      # Generate XML to attach the disk with unique WWN
      xml_file="/tmp/disk-$i-$j.xml"
      cat > "$xml_file" <<EOF
<disk type='file' device='disk'>
  <driver name='qemu' type='raw'/>
  <source file='$disk_path'/>
  <target dev='$target_dev' bus='scsi'/>
  <wwn>$wwn</wwn>
</disk>
EOF

      # Attach the disk to the VM live
      sudo virsh attach-device harvester-node-$i --file "$xml_file" --live
      disk_index=$((disk_index + 1))
    done
  done
fi
```

### 3_ Rancher integration

The last part allows the integration of the Harvester cluster with a pre-existing Rancher cluster.

Take a look [here](https://github.com/rancher/harvester-cloud/blob/main/projects/google-cloud/README.md#demostration-2---cluster-harvester-with-minimal-possible-configuration-that-is-automatically-added-to-a-rancher-cluster) for the demonstration.
