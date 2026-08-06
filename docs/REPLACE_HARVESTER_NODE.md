# How to delete a Harvester node and join a new one to an existing cluster

This documentation explains how to replace a node of a Harvester cluster deployed with the `harvester-cloud` project, without redeploying the whole cluster. The node is first removed from the cluster (via the Harvester UI or the command line), then the nested virtual machine is destroyed and recreated, and finally the new node joins the existing cluster.

All examples in this guide were tested on a 3-node Harvester cluster deployed on AWS. With minor changes, the same procedure applies to the other cloud providers, as only the way you reach the cloud instance differs.

## IMPORTANT: understand what a "node" is in this project

The `harvester-cloud` project creates **one cloud instance per deployment**, not one instance per Harvester node. The Harvester nodes are **nested KVM virtual machines** running inside that single cloud instance.

```console
AWS EC2 instance (openSUSE Leap, nested virtualization enabled)
 ├─ nginx + dnsmasq (HTTP/PXE boot server on 192.168.122.1)
 ├─ libvirt network vlan1 (192.168.122.0/24, NAT, DHCP)
 ├─ harvester-node-1   → /mnt/datadisk1/harvester-data.qcow2   → VNC 5901
 ├─ harvester-node-2   → /mnt/datadisk2/harvester-data.qcow2   → VNC 5902
 └─ harvester-node-3   → /mnt/datadisk3/harvester-data.qcow2   → VNC 5903
```

Consequences:

* There is **no Terraform/OpenTofu resource representing a single Harvester node**. Running `tofu apply -replace=...` on the instance rebuilds the cloud instance, which means rebuilding the entire cluster. Node replacement is a `virsh` operation performed on the cloud instance.
* The nodes are installed by PXE boot. The file `/srv/www/harvester/default.ipxe` is **shared by every node** and points to a single cloud-config file at a time. Only replace **one node at a time**.
* `192.168.122.120` is the **cluster VIP** (`vip_mode: static` in `create_cloud_config.yaml`), not a node address. It floats to a surviving node, so removing a node does not break the Harvester UI, the `socat` proxy, or the kubeconfig.

## PREREQUISITES:

* A Harvester cluster deployed with `harvester-cloud` and up and running.
The examples in this guide were tested on a Harvester cluster deployed on AWS using the variables below.

```console
cat harvester-cloud/projects/aws/terraform.tfvars

prefix = "my-harvester"
region = "us-east-1"
harvester_version = "v1.5.1"
harvester_node_count = 3
harvester_cluster_size = "small"
data_disk_count = 1
data_disk_size = 350
harvester_witness_node = false
```

* SSH access to the cloud instance, using the key files generated in the project directory.

```console
cd harvester-cloud/projects/aws
ls -lrth *ssh*
-rw------- 1 mary mary  387B Aug  5 15:59 my-harvester-ssh_private_key.pem
-rw------- 1 mary mary   81B Aug  5 15:59 my-harvester-ssh_public_key.pem

tofu output
first_instance_public_ip = "3.87.10.44"
harvester_url = "https://my-harvester.3.87.10.44.sslip.io"
longhorn_url = "https://my-harvester.3.87.10.44.sslip.io/dashboard/c/local/longhorn"
```

```console
ssh -i my-harvester-ssh_private_key.pem opensuse@3.87.10.44
```

* The cluster kubeconfig, to run `kubectl` commands from your local CLI.

```console
export KUBECONFIG=$PWD/my-harvester_kube_config.yml
kubectl get nodes
NAME               STATUS   ROLES                       AGE   VERSION
my-harvester-1   Ready    control-plane,etcd,master   3h    v1.32.4+rke2r1
my-harvester-2   Ready    control-plane,etcd,master   3h    v1.32.4+rke2r1
my-harvester-3   Ready    control-plane,etcd,master   3h    v1.32.4+rke2r1
```

* **A healthy cluster before you start.** On a 3-node cluster, removing one node leaves 2 etcd members: quorum is preserved but there is no fault tolerance until the replacement has joined. Do not reboot the cloud instance and do not remove a second node during the procedure.

## PROCEDURE

### 1. Identify the node to be replaced

Each Harvester node maps to a nested VM, a data disk, and a cloud-config file on the cloud instance. Note the index, you will need it in every following step.

```console
ip-10-10-0-122:~ # virsh list --all
 Id   Name               State
----------------------------------
 4    harvester-node-1   running
 5    harvester-node-2   running
 6    harvester-node-3   running
```

| Harvester node | Nested VM | Disk | Cloud-config on the instance | VNC port |
| --- | --- | --- | --- | --- |
| my-harvester-1 | harvester-node-1 | `/mnt/datadisk1/harvester-data.qcow2` | `create_cloud_config.yaml` (`mode: create`) | 5901 |
| my-harvester-2 | harvester-node-2 | `/mnt/datadisk2/harvester-data.qcow2` | `join_cloud_config.yaml` | 5902 |
| my-harvester-3 | harvester-node-3 | `/mnt/datadisk3/harvester-data.qcow2` | `join_cloud_config_2.yaml` | 5903 |

**The first node is a special case.** `create_cloud_config.yaml` uses `mode: create`, which builds a *new* cluster. A rebuilt `harvester-node-1` must always be reinstalled with a **join** configuration, as described in step 4. Never PXE boot a replacement node with `create_cloud_config.yaml` while the cluster is running: it would create a second, separate cluster.

### 2. Delete the node from the Harvester cluster

Removing the node from the cluster first is mandatory. It drains the workloads, removes the etcd member, and lets Longhorn start rebuilding the replicas that lived on that node.

#### Option A - Harvester UI

1. Open the Harvester UI (`harvester_url` from `tofu output`) and log in.
2. Go to **Hosts**.
3. Click the **⋮** menu on the node to be removed and select **Delete**.
4. Confirm the deletion and wait until the node disappears from the list.

#### Option B - Command line

```console
kubectl cordon my-harvester-1
kubectl drain my-harvester-1 --ignore-daemonsets --delete-emptydir-data
kubectl delete node my-harvester-1
```

Verify that only the surviving nodes are left, and that the **Hosts** page in the UI no longer lists the deleted node. A stale entry there means the etcd member was not removed and the new node will fail to join.

```console
kubectl get nodes
NAME               STATUS   ROLES                       AGE   VERSION
my-harvester-2   Ready    control-plane,etcd,master   3h    v1.32.4+rke2r1
my-harvester-3   Ready    control-plane,etcd,master   3h    v1.32.4+rke2r1
```

### 3. Destroy the nested VM and wipe its disk

Connect to the cloud instance and become root. A cron job (`/usr/local/bin/restart_harvester_vms_script.sh`) runs every 2 minutes in **root's** crontab and restarts any VM found in the `shut off` state, so run `destroy` and `undefine` as a single chained command.
**NOTE**: Comment the cronjob before you delete the VM, to not be created during the operation.

```console
ip-10-10-0-122:~ # sudo crontab -l
*/2 * * * * /usr/local/bin/restart_harvester_vms_script.sh
```

```console
ip-10-10-0-122:~ # N=1
ip-10-10-0-122:~ # sudo virsh destroy harvester-node-$N && sudo virsh undefine harvester-node-$N --nvram
Domain 'harvester-node-1' destroyed

Domain 'harvester-node-1' has been undefined
```

`--nvram` is required because the nested VMs boot with an OVMF pflash firmware; `undefine` fails without it.

Delete the qcow2 disk so the new node is installed from scratch:

```console
ip-10-10-0-122:~ # sudo rm -f /mnt/datadisk$N/harvester-data.qcow2
```

If `virt-install` later reports `Disk ... is already in use by other guests`, the domain still exists. Check the index you are using — do **not** pass `--check path_in_use=off`, as that would let two guests write to the same disk image.

### 4. Prepare the cloud-config for the new node

Every replacement node, including node 1, must use a **join** configuration. Create a dedicated file so the existing ones are left untouched:

```console
ip-10-10-0-122:~ # N=<node-index>
ip-10-10-0-122:~ # sudo cp /srv/www/harvester/join_cloud_config.yaml \
    /srv/www/harvester/join_cloud_config_node$N.yaml
ip-10-10-0-122:~ # sudo sed -i "s/  hostname:.*/  hostname: my-harvester-$N/" \
    /srv/www/harvester/join_cloud_config_node$N.yaml
```

If the cluster was deployed with `harvester_witness_node = true` and the node being replaced is the witness node, also change its role:

```console
ip-10-10-0-122:~ # sudo sed -i "s/  role: default/  role: witness/" \
    /srv/www/harvester/join_cloud_config_node$N.yaml
```

Check the result. `mode` must be `join`, `server_url` must point to the VIP, and the token must match the one used by the cluster:

```console
ip-10-10-0-122:~ # cat /srv/www/harvester/join_cloud_config_node1.yaml
#cloud-config
scheme_version: 1
server_url: https://192.168.122.120:443
token: SecretToken.123
os:
  hostname: my-harvester-1
  password: harvester
  ntp_servers:

    - 0.suse.pool.ntp.org
    - 1.suse.pool.ntp.org

install:
  role: default
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
  iso_url: http://192.168.122.1/harvester-v1.5.1-amd64.iso
  tty: tty1,115200n8
```

### 5. Point the PXE boot file to the new cloud-config

`default.ipxe` is shared by all nodes booting on the `vlan1` network. Update it so the replacement node fetches the file created in the previous step:

```console
ip-10-10-0-122:~ # sudo sed -i "s|join_cloud_config[^ ]*\.yaml|join_cloud_config_node$N.yaml|" \
    /srv/www/harvester/default.ipxe
ip-10-10-0-122:~ # #confirm the URL
ip-10-10-0-122:~ # grep config_url /srv/www/harvester/default.ipxe
    harvester.install.config_url=http://192.168.122.1/join_cloud_config_node1.yaml \
```

Because this file is global, only one node may be installing at any given time.

### 6. (Optional) Reserve a fixed IP address for the new node

The nested VMs get their address from the libvirt DHCP server on `vlan1`. A recreated node uses a new MAC address, and therefore normally gets a different IP. To know the address in advance, add a static reservation before creating the VM:

```console
ip-10-10-0-122:~ # sudo virsh net-update vlan1 add ip-dhcp-host \
    "<host mac='52:54:00:aa:bb:01' name='my-harvester-1' ip='192.168.122.101'/>" \
    --live --config
```

Do not use `192.168.122.1` (the gateway of the cloud instance) or `192.168.122.120` (the cluster VIP).

### 7. Create the new nested VM

Reuse exactly the same specification as the original node. The authoritative values for your deployment are in the generated `projects/<provider>/harvester_startup_script.sh` file — for a 3-node `small` cluster with `data_disk_size = 350`, that is 32768 MB of memory, 8 vCPUs and a 315 GB disk.
**NOTE**: check the --name and --disk path values before you run the command. Use the index of the node you want to create.

```console
ip-10-10-0-122:~ # sudo virt-install --name harvester-node-1 --memory 32768 --vcpus 8 --cpu host-passthrough \
    --disk path=/mnt/datadisk1/harvester-data.qcow2,size=315,bus=virtio,format=qcow2 \
    --boot loader=/usr/share/qemu/ovmf-x86_64-code.bin,loader_ro=yes,loader_type=pflash,nvram_template=/usr/share/qemu/ovmf-x86_64-vars.bin \
    --os-variant generic \
    --network bridge=virbr1,model=virtio \
    --graphics vnc,listen=0.0.0.0,password=yourpass,port=5901 \
    --console pty,target_type=serial --pxe --autostart
```

Adapt the node name, the `datadisk` index and the VNC port to the node you are replacing. If you reserved a MAC address in step 6, add it to the network option: `--network bridge=virbr1,model=virtio,mac=52:54:00:aa:bb:01`.

The `--os-type` flag used by older versions of the deployment script is deprecated and can be omitted.

### 8. Follow the installation

The installer writes to `tty1`, not to the serial port, so `virsh console` stays blank during the installation. Use one of the methods below.

#### Graphical console through a browser

Start a websockify proxy on the cloud instance for the VNC port of the node (5901 for node 1), then open `http://<instance-public-ip>:6080/vnc.html` and enter the VNC password `yourpass`:

```console
ip-10-10-0-122:~ # websockify --web /usr/share/novnc/ --wrap-mode=ignore 6080 localhost:5901
```

Port 6080 is only open to the CIDRs in `public_ip_source_addresses`. If your public IP has changed since the deployment, forward the port over SSH instead and browse `http://localhost:6080/vnc.html`:

```console
ssh -i my-harvester-ssh_private_key.pem -L 6080:localhost:6080 opensuse@3.87.10.44
```

See [How to access the Harvester nodes' serial console through a browser](https://github.com/rancher/harvester-cloud/blob/main/docs/HARVESTER_NODES_SERIAL_CONSOLE.md) for more details.

#### Single screenshot

```console
ip-10-10-0-122:~ # sudo virsh screenshot harvester-node-1 /tmp/node1.ppm
```

#### Progress from the HTTP server logs

All installation artifacts are served by the local nginx, so the access log acts as a progress indicator:

```console
ip-10-10-0-122:~ # sudo tail -f /var/log/nginx/access.log
```

The expected sequence is `ipxe.efi` → `default.ipxe` → `harvester-<version>-vmlinuz-amd64` → `harvester-<version>-initrd-amd64` → `harvester-<version>-rootfs-amd64.squashfs` → `join_cloud_config_node<N>.yaml` → `harvester-<version>-amd64.iso`.

**If `join_cloud_config_node<N>.yaml` never appears in the log, stop and go back to step 5** — the node is booting with the wrong configuration and will come up with the wrong hostname or role.

The ISO download is the long phase. The disk image is sparse, so its allocated size grows as the installation progresses:

```console
ip-10-10-0-122:~ # watch -n5 'du -h /mnt/datadisk1/harvester-data.qcow2'
```

### 9. Verify that the new node has joined

The node reboots automatically at the end of the installation and joins the cluster.

```console
kubectl get nodes -w
NAME               STATUS     ROLES                       AGE   VERSION
my-harvester-1   NotReady   control-plane,etcd,master   30s   v1.32.4+rke2r1
my-harvester-2   Ready      control-plane,etcd,master   3h    v1.32.4+rke2r1
my-harvester-3   Ready      control-plane,etcd,master   3h    v1.32.4+rke2r1

my-harvester-1   Ready      control-plane,etcd,master   2m    v1.32.4+rke2r1
```

Find the address assigned to the new node and log in with the user `rancher` and the password defined in the cloud-config (`harvester` by default):

```console
ip-10-10-0-122:~ # sudo virsh domifaddr harvester-node-1 --source lease
 Name       MAC address          Protocol     Address
-------------------------------------------------------------------------------
 vnet0      52:54:00:aa:bb:01    ipv4         192.168.122.101/24
```

```console
ip-10-10-0-122:~ # ssh rancher@192.168.122.101
```

SSH is only available **after** the installation has completed and the node has rebooted. While the node is still in the installer, the cloud-config password does not apply yet.

Finally, check in the Harvester UI that the host is `Active` and, under **Longhorn**, that the volume replicas have finished rebuilding on the new node. Do not replace another node before all volumes are healthy.

### 10. Restore the cluster to its steady state

1. Make sure the watchdog cron job is active in **root's** crontab. It is easy to leave it commented out while troubleshooting; without it, a nested VM that ends up in the `shut off` state is never restarted.

```console
ip-10-10-0-122:~ # sudo crontab -l
*/2 * * * * /usr/local/bin/restart_harvester_vms_script.sh
```

2. Terraform/OpenTofu state is not affected by this procedure, since the nested VMs were never part of the state. A `tofu plan` in the project directory should report no changes.

```console
cd harvester-cloud/projects/aws
tofu plan
No changes. Your infrastructure matches the configuration.
```

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| `Disk ... is already in use by other guests` | The target domain still exists, or the wrong node index was used in the `virt-install` command | Check `virsh list --all` and the disk path; never use `--check path_in_use=off` |
| `Requested operation is not valid: cannot undefine domain with nvram` | Missing `--nvram` flag | `virsh undefine <name> --nvram` |
| The VM restarts by itself right after `virsh destroy` | The watchdog cron job restarted it before it was undefined | Chain `destroy` and `undefine` in a single command |
| A second cluster appears instead of a new node | The node booted with `create_cloud_config.yaml` | Destroy the VM, fix `default.ipxe` (step 5) and reinstall |
| The new node never appears in `kubectl get nodes` | Wrong `token` or `server_url`, or a stale etcd member for the old node | Compare the token with `create_cloud_config.yaml`; remove the stale host from the UI |
| `virsh console` shows nothing | The installer writes to `tty1`, not to the serial port | Use the VNC/noVNC console (step 8) |
| The `rancher` password is rejected | The node is still running the installer | Wait for the installation to finish and the node to reboot |
| `crontab -l` reports `no crontab for opensuse` | The watchdog lives in root's crontab | Use `sudo crontab -l` |
