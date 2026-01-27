# Implement Cross-Cluster Kubernetes Disaster Recovery with Rancher using Harvester (harvester-cloud) as Cloud Provider.

## Architecture Overview

```console
Rancher Server (Management Kubernetes Cluster)
 ├─ Longhorn (Persistent Block Storage / CSI)
 │   └─ Persistent Volumes for MinIO
 │
 └─ MinIO (S3-compatible Object Storage)
     └─ Bucket: velero-backups

Harvester Cluster AAA
 └─ RKE2 Cluster AAA
     └─ Velero
         └─ Backups → MinIO (on Rancher Server)

Harvester Cluster BBB
 └─ RKE2 Cluster BBB (empty / DR target)
     └─ Velero
         └─ Restores ← MinIO (on Rancher Server)
```

### Disaster Recovery Workflow

1. Rancher provisions RKE2 Cluster AAA on Harvester AAA
2. Velero backs up RKE2 Cluster AAA to MinIO on Rancher Server
3. A failure occurs on Harvester AAA or RKE2 Cluster AAA
4. Rancher provisions RKE2 Cluster BBB on Harvester BBB
5. Velero restores the backup from MinIO into RKE2 Cluster BBB
6. Applications and data are recovered on Harvester BBB

### Key Principles

- Velero runs inside each RKE2 cluster
- MinIO runs outside the protected RKE2 clusters
- Longhorn provides persistent storage for MinIO
- Backup storage is centralized and S3-compatible
- No VM-level or node-level backups are involved

## Prerequisites

### Infrastructure Deployment

Before starting the Disaster Recovery workflow, the following infrastructure components must be in place:

1. A **Rancher Server Kubernetes cluster** deployed and operational
  - The cluster must have **additional data disks attached to the nodes**
  - These disks are required for deploying **Longhorn** as persistent storage
  - Longhorn will be used to provide persistent volumes for MinIO
2. **Two Harvester clusters** already deployed and managed by Rancher
  - Harvester Cluster AAA (primary site)
  - Harvester Cluster BBB (disaster recovery site)
3. Rancher must be able to:
  - Provision RKE2 clusters on both Harvester clusters
  - Manage lifecycle operations for the downstream Kubernetes clusters

**If the infrastructure is not already prepared, it must be deployed before following this guide.**

#### Rancher Deployment

1. Clone the Repository

```bash
cd 
git clone git@github.com:rancher/tf-rancher-up.git
cd tf-rancher-up
```

2. Configure the `variables` File

Assuming the lab will be based on Microsoft Azure, before running the Terraform code to deploy Rancher, you'll need to configure the environment-specific variables. You'll find the `terraform.tfvars.example` file in the recipe's root directory.

Copy this example file and rename it to `terraform.tfvars`:

```bash
cd recipes/upstream/azure/rke2
cp terraform.tfvars.example terraform.tfvars
vi terraform.tfvars
```

Example:

```console
$ cat terraform.tfvars
prefix           = "demo-rancher-gl"
subscription_id  = "************"
region           = "italynorth"
instance_count   = 3
instance_type    = "Standard_D8_v5"
rancher_hostname = "demo-rancher-gl"
rancher_password = "************"
```

3. Terraform Deploy

```bash
terraform init -upgrade && terraform apply -auto-approve
```

4. Create an API Key

To integrate Harvester clusters, you'll need to create an API key.
The [official documentation](https://ranchermanager.docs.rancher.com/reference-guides/user-settings/api-keys#creating-an-api-key) explains this process very well.

5. Enable the Harvester UI Extension

The [official documentation](https://docs.harvesterhci.io/v1.6/rancher/harvester-ui-extension) explains this process very well.

6. Install Longhorn Requirements

```bash
# Make sure you are in the path where the Terraform code used to deploy Rancher is located
# recipes/upstream/azure/rke2
cat <<'EOF' > prepare-longhorn.sh
#!/usr/bin/env bash

OS_TYPE=$(grep -E '^\s*os_type\s*=' terraform.tfvars 2>/dev/null \
  | head -1 \
  | cut -d= -f2- \
  | tr -d ' "')

if [[ -z "$OS_TYPE" ]]; then
  OS_TYPE=$(awk '
    /variable "os_type"/ {found=1}
    found && /default/ {
      gsub(/[" ]/,"",$3)
      print $3
      exit
    }
  ' variables.tf)
fi

PREFIX=$(grep -E '^\s*prefix\s*=' terraform.tfvars 2>/dev/null \
  | head -1 \
  | cut -d= -f2- \
  | tr -d ' "')

if [[ -z "$PREFIX" ]]; then
  PREFIX=$(awk '
    /variable "prefix"/ {found=1}
    found && /default/ {
      gsub(/[" ]/,"",$3)
      print $3
      exit
    }
  ' variables.tf)
fi

case "$OS_TYPE" in
  sles)
    SSH_USER="sles"
    ;;
  opensuse)
    SSH_USER="opensuse"
    ;;
  *)
    SSH_USER="ubuntu"
    ;;
esac

SSH_KEY="${PREFIX}-ssh_private_key.pem"

for IP in $(terraform output instances_public_ip | tr -d '[]" ,' | tr '\n' ' '); do
  ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i "$SSH_KEY" "$SSH_USER@$IP" "
    sudo zypper --non-interactive addrepo https://download.opensuse.org/repositories/network/SLE_15/network.repo || true
    sudo zypper --non-interactive --gpg-auto-import-keys refresh
    sudo zypper --non-interactive install -y open-iscsi
    sudo systemctl enable iscsid
    sudo systemctl start iscsid
  "
done
EOF
```

```bash
chmod +x prepare-longhorn.sh
sh prepare-longhorn.sh
```

7. Install Longhorn from the UI

The [official documentation](https://longhorn.io/docs/1.10.1/deploy/install/install-with-rancher/) explains this process very well.

8. Install MinIO Operator from the UI

The [official documentation](https://documentation.suse.com/trd/minio/html/gs_rancher_minio/index.html#id-install-minio-from-suse-rancher-apps-marketplace) explains this process very well.

**Remember to specify the creation of a new namespace, which for convenience can be called `minio-operator`.**

9. Configure a MinIO object storage completely from the CLI

```bash
# Install the MinIO Kubernetes plugin
kubectl krew install minio
kubectl minio version
```

```bash
export KUBECONFIG=demo-rancher-gl_kube_config.yml # <PREFIX>__kube_config.yml
# Create the Tenant namespace
kubectl create namespace minio-tenant
```

```bash
# Apply NodePort Services for MinIO API and Console
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: minio-nodeport
  namespace: minio-tenant
spec:
  type: NodePort
  selector:
    v1.min.io/tenant: minio
    v1.min.io/pool: ss-0
  ports:
    - port: 9000
      targetPort: 9000
      nodePort: 30090
---
apiVersion: v1
kind: Service
metadata:
  name: minio-console-nodeport
  namespace: minio-tenant
spec:
  type: NodePort
  selector:
    v1.min.io/tenant: minio
    v1.min.io/console: minio-console
  ports:
    - port: 9090
      targetPort: 9090
      nodePort: 30091
EOF
```

```bash
# Create a MinIO Tenant
kubectl minio tenant create minio \
  --namespace minio-tenant \
  --servers 1 \
  --volumes 1 \
  --capacity 10Gi \
  --storage-class longhorn \
  --disable-tls
## Wait until the MinIO pod is Running and Ready 2/2
while [[ $(kubectl -n minio-tenant get pod -l v1.min.io/tenant=minio -o jsonpath="{.items[0].status.containerStatuses[*].ready}") != "true true" ]]; do echo "Waiting for MinIO pod..."; sleep 5; done
```

```bash
# Create the Bucket (AWS S3 Compatible Object Storage)
## Install the MinIO Client (It is the equivalent of aws s3 but designed specifically for MinIO)
brew install minio/stable/mc # Ref. https://github.com/minio/mc
## Retrieve credentials from the MinIO secret
export MINIO_ROOT_USER=$(kubectl get secret minio-env-configuration -n minio-tenant \
  -o jsonpath="{.data.config\.env}" | base64 --decode | grep MINIO_ROOT_USER | cut -d'"' -f2)
export MINIO_ROOT_PASSWORD=$(kubectl get secret minio-env-configuration -n minio-tenant \
  -o jsonpath="{.data.config\.env}" | base64 --decode | grep MINIO_ROOT_PASSWORD | cut -d'"' -f2)
## Retrieve the MinIO NodePort and node IP automatically
export MINIO_NODE_PORT=$(kubectl get svc minio-nodeport -n minio-tenant -o jsonpath="{.spec.ports[0].nodePort}")
export MINIO_NODE_NAME=$(kubectl -n minio-tenant get pod -l v1.min.io/tenant=minio -o jsonpath="{.items[0].spec.nodeName}")
export MINIO_NODE_IP=$(kubectl get node $MINIO_NODE_NAME -o jsonpath="{.status.addresses[?(@.type=='ExternalIP')].address}")
## Create the Bucket for Velero
mc --config-dir /tmp/.mc alias set minio http://$MINIO_NODE_IP:$MINIO_NODE_PORT $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD
mc --config-dir /tmp/.mc mb minio/velero-backups
mc --config-dir /tmp/.mc ls minio
rm -rf /tmp/.mc
```

Example:

```console
$ mc --config-dir /tmp/.mc alias set minio http://$MINIO_NODE_IP:$MINIO_NODE_PORT $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD
mc: Configuration written to `/tmp/.mc/config.json`. Please update your access credentials.
mc: Successfully created `/tmp/.mc/share`.
mc: Initialized share uploads `/tmp/.mc/share/uploads.json` file.
mc: Initialized share downloads `/tmp/.mc/share/downloads.json` file.
Added `minio` successfully.
$ mc --config-dir /tmp/.mc mb minio/velero-backups
Bucket created successfully `minio/velero-backups`.
$ mc --config-dir /tmp/.mc ls minio
[2026-01-15 10:29:54 CET]     0B velero-backups/
```

If you're new to *krew*, the plugin manager for *kubectl*, follow [these](https://krew.sigs.k8s.io/docs/user-guide/setup/install/) steps to install it.

#### Harvester Cluster AAA Deployment

1. Clone the Repository

```bash
cd
git clone git@github.com:rancher/harvester-cloud.git
cd harvester-cloud
```

2. Configure the `variables` File

Assuming the lab will be based on Microsoft Azure, before running the Terraform code to deploy Harvester, you'll need to configure the environment-specific variables. You'll find the `terraform.tfvars.example` file in the recipe's root directory.

Copy this example file and rename it to `terraform.tfvars`:

```bash
cd projects/azure
cp terraform.tfvars.example terraform.tfvars
vi terraform.tfvars
```

Example:

```console
$ cat terraform.tfvars
prefix               = "hrv-gl-aaa"
subscription_id      = "************"
spot_instance        = false
region               = "italynorth"
harvester_node_count = 3
rancher_api_url      = "https://demo-rancher-gl.<PUBLIC_IP>.sslip.io"
rancher_access_key   = "************"
rancher_secret_key   = "************"
rancher_insecure     = true
```

3. Terraform Deploy

```bash
terraform init -upgrade && terraform apply -auto-approve
```

4. Upload an OS image that will then be used with VM deployments

```console
$ pwd
~/harvester-cloud/projects/azure
```

```bash
cd ../harvester-ops/image-creation/
vi terraform.tfvars
```

Example:

```console
$ cat terraform.tfvars
harvester_url        = "https://hrv-gl-aaa.<PUBLIC_IP>.sslip.io"
kubeconfig_file_path = "../../azure/"
kubeconfig_file_name = "hrv-gl-aaa_kube_config.yml"
```

```bash
terraform init -upgrade && terraform apply -auto-approve
```

5. Create a VM Network

```console
$ pwd
~/harvester-cloud/projects/harvester-ops/image-creation
```

```bash
cd ../network-creation/
vi terraform.tfvars
```

Example:

```console
$ cat terraform.tfvars
harvester_url             = "https://hrv-gl-aaa.<PUBLIC_IP>.sslip.io"
kubeconfig_file_path      = "../../azure/"
kubeconfig_file_name      = "hrv-gl-aaa_kube_config.yml"
private_ssh_key_file_path = "../../azure/"
private_ssh_key_file_name = "hrv-gl-aaa-ssh_private_key.pem"
cluster_network_count     = 3
```

```bash
terraform init -upgrade && terraform apply -auto-approve
```

#### Harvester Cluster BBB Deployment

It will follow the same path as the previous point.

At the end of this phase, the environment must provide:
- One Rancher Server cluster
- Two Harvester clusters managed by Rancher
- A working base infrastructure ready for the Disaster Recovery workflow

The following sections describe the configuration required to enable cross-cluster Kubernetes Disaster Recovery.

## DR Workflow Setup Instructions

### Create the RKE2 AAA Cluster on Harvester AAA from UI

The [official documentation](https://docs.harvesterhci.io/v1.7/rancher/node/rke2-cluster/) explains this process very well.

**Remember to click on `Show Advanced` and change the parameters in `User Data:` with:**

```console
#cloud-config
package_update: true

packages:
  - qemu-guest-agent

users:
  - name: opensuse
    gecos: opensuse User
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false

chpasswd:
  list: |
    opensuse:opensuse
  expire: false

runcmd:
  - systemctl enable --now qemu-guest-agent.service
  - sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
  - sed -i 's@Include /etc/ssh/sshd_config.d/\*.conf@#Include /etc/ssh/sshd_config.d/*.conf@g' /etc/ssh/sshd_config
  - systemctl restart ssh
```

**It is recommended to change the CNI from Calico to Cilium to avoid encountering errors regarding IP addressing.**

![](./images/CROSS_CLUSTER_K8S_DR_1.png)
![](./images/CROSS_CLUSTER_K8S_DR_2.png)

### Install Velero from the RKE2 AAA CLI

After a few minutes...

![](./images/CROSS_CLUSTER_K8S_DR_3.png)

```bash
# Return to the Harvester Cloud project. From the last commands you ran, you should be in the path ~/harvester-cloud/projects/harvester-ops/network-creation
cd ../../azure/
# Connect to the Harvester Cluster
export KUBECONFIG=./hrv-gl-aaa_kube_config.yml
```

```console
# Connect to a VM in the RKE2 Cluster
$ kubectl get vmi -A
NAMESPACE   NAME                         AGE   PHASE     IP                NODENAME       READY
default     rke2-aaa-pool1-bgfbr-82v5m   27m   Running   192.168.123.186   hrv-gl-aaa-2   True
$ virtctl ssh --local-ssh=true opensuse@vmi/rke2-aaa-pool1-bgfbr-82v5m.default
The authenticity of host 'vmi/rke2-aaa-pool1-bgfbr-82v5m.default (<no hostip for proxy command>)' can't be established.
ED25519 key fingerprint is SHA256:fsPfS38iAQJsI5sJExka4dEtGG7VUZ0ag4idxdAOCOk.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'vmi/rke2-aaa-pool1-bgfbr-82v5m.default' (ED25519) to the list of known hosts.
(opensuse@vmi/rke2-aaa-pool1-bgfbr-82v5m.default) Password: 
Have a lot of fun...
opensuse@rke2-aaa-pool1-bgfbr-82v5m:~> sudo su -
rke2-aaa-pool1-bgfbr-82v5m:~ # 
```

**Remember to retrieve the `MINIO_ROOT_USER`, `MINIO_ROOT_PASSWORD`, `MINIO_NODE_PORT`, `MINIO_NODE_NAME` and `MINIO_NODE_IP` environment variables from the Rancher Cluster (take a look above, where the installation of MinIO is described).**

```console
# Export the variables needed for login to MinIO
rke2-aaa-pool1-bgfbr-82v5m:~ # export MINIO_ROOT_USER=R07N5STVMZK4HJ6HOB9F
rke2-aaa-pool1-bgfbr-82v5m:~ # export MINIO_ROOT_PASSWORD=cFg9kVAbwulpOEkiJoMfXsMRDMSzH6oNrWkpVAQK
rke2-aaa-pool1-bgfbr-82v5m:~ # export MINIO_NODE_PORT=30090
rke2-aaa-pool1-bgfbr-82v5m:~ # export MINIO_NODE_NAME=demo-rancher-gl-vm-3
rke2-aaa-pool1-bgfbr-82v5m:~ # export MINIO_NODE_IP=172.213.211.81
# Install the Velero Client
rke2-aaa-pool1-bgfbr-82v5m:~ # export VELERO_VERSION=v1.17.1
rke2-aaa-pool1-bgfbr-82v5m:~ # curl -LO https://github.com/vmware-tanzu/velero/releases/download/${VELERO_VERSION}/velero-${VELERO_VERSION}-linux-amd64.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 55.7M  100 55.7M    0     0  13.1M      0  0:00:04  0:00:04 --:--:-- 7986k
rke2-aaa-pool1-bgfbr-82v5m:~ # tar -xvf velero-${VELERO_VERSION}-linux-amd64.tar.gz
velero-v1.17.1-linux-amd64/LICENSE
velero-v1.17.1-linux-amd64/examples/minio/00-minio-deployment.yaml
velero-v1.17.1-linux-amd64/examples/nginx-app/README.md
velero-v1.17.1-linux-amd64/examples/nginx-app/base.yaml
velero-v1.17.1-linux-amd64/examples/nginx-app/with-pv.yaml
velero-v1.17.1-linux-amd64/velero
rke2-aaa-pool1-bgfbr-82v5m:~ # sudo mv velero-${VELERO_VERSION}-linux-amd64/velero /usr/local/bin/
rke2-aaa-pool1-bgfbr-82v5m:~ # velero version
An error occurred: error finding Kubernetes API server config in --kubeconfig, $KUBECONFIG, or in-cluster configuration: invalid configuration: no configuration has been provided, try setting KUBERNETES_MASTER environment variable
rke2-aaa-pool1-bgfbr-82v5m:~ # export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
rke2-aaa-pool1-bgfbr-82v5m:~ # velero version
Client:
	Version: v1.17.1
	Git commit: 94f64639cee09c5caaa65b65ab5f42175f41c101
<error getting server version: unable to retrieve the complete list of server APIs: velero.io/v1: no matches for velero.io/v1, Resource=>
rke2-aaa-pool1-bgfbr-82v5m:~ # velero install \
>   --provider aws \
>   --plugins velero/velero-plugin-for-aws:v1.13.1 \
>   --bucket velero-backups \
>   --secret-file <(echo "[default]
> aws_access_key_id=$MINIO_ROOT_USER
> aws_secret_access_key=$MINIO_ROOT_PASSWORD") \
>   --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://$MINIO_NODE_IP:$MINIO_NODE_PORT \
>   --use-volume-snapshots=false
...
...
...
Deployment/velero: created
Velero is installed! ⛵ Use 'kubectl logs deployment/velero -n velero' to view the status.
rke2-aaa-pool1-bgfbr-82v5m:~ #
```

```bash
# For convenient copy and paste
velero install \
  --provider aws \
  --plugins velero/velero-plugin-for-aws:v1.13.1 \
  --bucket velero-backups \
  --secret-file <(echo "[default]
aws_access_key_id=$MINIO_ROOT_USER
aws_secret_access_key=$MINIO_ROOT_PASSWORD") \
  --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://$MINIO_NODE_IP:$MINIO_NODE_PORT \
  --use-volume-snapshots=false
```

```console
rke2-aaa-pool1-bgfbr-82v5m:~ # velero backup-location get default
NAME      PROVIDER   BUCKET/PREFIX    PHASE       LAST VALIDATED                  ACCESS MODE   DEFAULT
default   aws        velero-backups   Available   2026-01-14 15:53:38 +0000 UTC   ReadWrite     true
rke2-aaa-pool1-bgfbr-82v5m:~ # 
```

### Install a sample app on the RKE2 AAA Cluster to simulate a backup

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl create ns demo
kubectl -n demo create deployment nginx-demo --image=nginx:stable
kubectl -n demo expose deployment nginx-demo --type=NodePort --port=80
```

### Create a Velero backup of the demo namespace created in the previous step

```console
rke2-aaa-pool1-bgfbr-82v5m:~ # velero backup create backup-default --include-namespaces demo --wait
Backup request "backup-default" submitted successfully.
Waiting for backup to complete. You may safely press ctrl-c to stop waiting - your backup will continue in the background.
.
Backup completed with status: Completed. You may check for more information using the commands `velero backup describe backup-default` and `velero backup logs backup-default`.
rke2-aaa-pool1-bgfbr-82v5m:~ # velero backup get
NAME             STATUS      ERRORS   WARNINGS   CREATED                         EXPIRES   STORAGE LOCATION   SELECTOR
backup-default   Completed   0        0          2026-01-14 15:54:38 +0000 UTC   29d       default            <none>
rke2-aaa-pool1-bgfbr-82v5m:~ #
```

### Delete everything from the demo namespace and try a restore on the RKE2 AAA Cluster itself

```console
rke2-aaa-pool1-bgfbr-82v5m:~ # kubectl delete all --all -n demo
pod "nginx-demo-bf7c6d495-8rg2f" deleted from demo namespace
service "nginx-demo" deleted from demo namespace
deployment.apps "nginx-demo" deleted from demo namespace
replicaset.apps "nginx-demo-bf7c6d495" deleted from demo namespace
rke2-aaa-pool1-bgfbr-82v5m:~ # kubectl -n demo get pods
No resources found in demo namespace.
rke2-aaa-pool1-bgfbr-82v5m:~ #
```

```console
rke2-aaa-pool1-bgfbr-82v5m:~ # velero restore create restore-demo --from-backup backup-default
Restore request "restore-demo" submitted successfully.
Run `velero restore describe restore-demo` or `velero restore logs restore-demo` for more details.
rke2-aaa-pool1-bgfbr-82v5m:~ # velero restore describe restore-demo
Name:         restore-demo
Namespace:    velero
Labels:       <none>
Annotations:  <none>

Phase:                       Completed
Total items to be restored:  10
Items restored:              10

Started:    2026-01-14 15:59:38 +0000 UTC
Completed:  2026-01-14 15:59:40 +0000 UTC

Warnings:
  Velero:     <none>
  Cluster:  could not restore, CustomResourceDefinition:ciliumendpoints.cilium.io already exists. Warning: the in-cluster version is different than the backed-up version
  Namespaces: <none>

Backup:  backup-default

Namespaces:
  Included:  all namespaces found in the backup
  Excluded:  <none>

Resources:
  Included:        *
  Excluded:        nodes, events, events.events.k8s.io, backups.velero.io, restores.velero.io, resticrepositories.velero.io, csinodes.storage.k8s.io, volumeattachments.storage.k8s.io, backuprepositories.velero.io
  Cluster-scoped:  auto

Namespace mappings:  <none>

Label selector:  <none>

Or label selector:  <none>

Restore PVs:  auto

CSI Snapshot Restores: <none included>

Existing Resource Policy:   <none>
ItemOperationTimeout:       4h0m0s

Preserve Service NodePorts:  auto

Uploader config:


HooksAttempted:   0
HooksFailed:      0
rke2-aaa-pool1-bgfbr-82v5m:~ # kubectl -n demo get pods,svc
NAME                             READY   STATUS    RESTARTS   AGE
pod/nginx-demo-bf7c6d495-8rg2f   1/1     Running   0          65s

NAME                 TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/nginx-demo   NodePort   10.43.192.31   <none>        80:31375/TCP   64s
rke2-aaa-pool1-bgfbr-82v5m:~ #
```

### Create the RKE2 BBB Cluster on Harvester BBB from UI

Follow the procedure above.

### Install Velero from the RKE2 BBB CLI

Follow the procedure above.

### Restore the demo namespace and all its contents to the new RKE2 BBB Cluster, simulating a DR scenario

Complete environment result:

![](./images/CROSS_CLUSTER_K8S_DR_4.png)
![](./images/CROSS_CLUSTER_K8S_DR_5.png)

```console
# In the path where the code for the deployment of the Harvester BBB Cluster is located (example: ~/hrv-gl-bbb/harvester-cloud/projects/azure)
$ export KUBECONFIG=hrv-gl-bbb_kube_config.yml
$ kubectl get vmi -A
NAMESPACE   NAME                         AGE   PHASE     IP                NODENAME       READY
default     rke2-bbb-pool1-xc5q8-j55dw   15m   Running   192.168.123.128   hrv-gl-bbb-2   True
$ virtctl ssh --local-ssh=true opensuse@vmi/rke2-bbb-pool1-xc5q8-j55dw.default
The authenticity of host 'vmi/rke2-bbb-pool1-xc5q8-j55dw.default (<no hostip for proxy command>)' can't be established.
ED25519 key fingerprint is SHA256:yuKUntKr0EKCrDHahYj9X1YLX8A5QdgvXijG/5dfKqo.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'vmi/rke2-bbb-pool1-xc5q8-j55dw.default' (ED25519) to the list of known hosts.
(opensuse@vmi/rke2-bbb-pool1-xc5q8-j55dw.default) Password: 
Have a lot of fun...
opensuse@rke2-bbb-pool1-xc5q8-j55dw:~> sudo su -
rke2-bbb-pool1-xc5q8-j55dw:~ # 
```

```console
# Export the variables needed for login to MinIO
rke2-bbb-pool1-xc5q8-j55dw:~ # export MINIO_ROOT_USER=NLV41D8JD3DRWW941PPS
rke2-bbb-pool1-xc5q8-j55dw:~ # export MINIO_ROOT_PASSWORD=OgOD0BYPIKhOhb8xXoAQNc6IqWQTzruJdeLurIW0
rke2-bbb-pool1-xc5q8-j55dw:~ # export MINIO_NODE_PORT=30090
rke2-bbb-pool1-xc5q8-j55dw:~ # export MINIO_NODE_NAME=demo-rancher-gl-vm-3
rke2-bbb-pool1-xc5q8-j55dw:~ # export MINIO_NODE_IP=4.232.188.13
# Install the Velero Client
rke2-bbb-pool1-xc5q8-j55dw:~ # export VELERO_VERSION=v1.17.1
rke2-bbb-pool1-xc5q8-j55dw:~ # curl -LO https://github.com/vmware-tanzu/velero/releases/download/${VELERO_VERSION}/velero-${VELERO_VERSION}-linux-amd64.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 55.7M  100 55.7M    0     0  75.8M      0 --:--:-- --:--:-- --:--:-- 94.8M
rke2-bbb-pool1-xc5q8-j55dw:~ # tar -xvf velero-${VELERO_VERSION}-linux-amd64.tar.gz
velero-v1.17.1-linux-amd64/LICENSE
velero-v1.17.1-linux-amd64/examples/minio/00-minio-deployment.yaml
velero-v1.17.1-linux-amd64/examples/nginx-app/README.md
velero-v1.17.1-linux-amd64/examples/nginx-app/base.yaml
velero-v1.17.1-linux-amd64/examples/nginx-app/with-pv.yaml
velero-v1.17.1-linux-amd64/velero
rke2-bbb-pool1-xc5q8-j55dw:~ # sudo mv velero-${VELERO_VERSION}-linux-amd64/velero /usr/local/bin/
rke2-bbb-pool1-xc5q8-j55dw:~ # export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
rke2-bbb-pool1-xc5q8-j55dw:~ # velero version
Client:
	Version: v1.17.1
	Git commit: 94f64639cee09c5caaa65b65ab5f42175f41c101
<error getting server version: unable to retrieve the complete list of server APIs: velero.io/v1: no matches for velero.io/v1, Resource=>
rke2-bbb-pool1-xc5q8-j55dw:~ # velero install \
>   --provider aws \
>   --plugins velero/velero-plugin-for-aws:v1.13.1 \
>   --bucket velero-backups \
>   --secret-file <(echo "[default]
> aws_access_key_id=$MINIO_ROOT_USER
> aws_secret_access_key=$MINIO_ROOT_PASSWORD") \
>   --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://$MINIO_NODE_IP:$MINIO_NODE_PORT \
>   --use-volume-snapshots=false
...
...
...
Deployment/velero: created
Velero is installed! ⛵ Use 'kubectl logs deployment/velero -n velero' to view the status.
rke2-bbb-pool1-xc5q8-j55dw:~ #
```

```console
rke2-bbb-pool1-xc5q8-j55dw:~ # velero backup-location get default
NAME      PROVIDER   BUCKET/PREFIX    PHASE       LAST VALIDATED                  ACCESS MODE   DEFAULT
default   aws        velero-backups   Available   2026-01-15 15:03:54 +0000 UTC   ReadWrite     true
rke2-bbb-pool1-xc5q8-j55dw:~ # 
```

```console
rke2-bbb-pool1-xc5q8-j55dw:~ # curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   138  100   138    0     0    755      0 --:--:-- --:--:-- --:--:--   758

100 55.8M  100 55.8M    0     0   112M      0 --:--:-- --:--:-- --:--:--  112M
rke2-bbb-pool1-xc5q8-j55dw:~ # chmod +x kubectl
rke2-bbb-pool1-xc5q8-j55dw:~ # sudo mv kubectl /usr/local/bin/
rke2-bbb-pool1-xc5q8-j55dw:~ # kubectl get ns
NAME                          STATUS   AGE
cattle-fleet-system           Active   15m
cattle-impersonation-system   Active   16m
cattle-local-user-passwords   Active   16m
cattle-system                 Active   19m
cilium-secrets                Active   19m
default                       Active   19m
kube-node-lease               Active   19m
kube-public                   Active   19m
kube-system                   Active   19m
local                         Active   16m
velero                        Active   4m3s
rke2-bbb-pool1-xc5q8-j55dw:~ # kubectl get pods -A | grep -i nginx-demo
rke2-bbb-pool1-xc5q8-j55dw:~ #
```

```console
# Create the demo namespace and sample app by restoring the backup made on the RKE2 AAA Cluster (running on the Harvester AAA Cluster)
rke2-bbb-pool1-xc5q8-j55dw:~ # velero restore create restore-demo --from-backup backup-default
Restore request "restore-demo" submitted successfully.
Run `velero restore describe restore-demo` or `velero restore logs restore-demo` for more details.
rke2-bbb-pool1-xc5q8-j55dw:~ # velero restore describe restore-demo
Name:         restore-demo
Namespace:    velero
Labels:       <none>
Annotations:  <none>

Phase:                       Completed
Total items to be restored:  11
Items restored:              11

Started:    2026-01-15 15:10:22 +0000 UTC
Completed:  2026-01-15 15:10:27 +0000 UTC

Warnings:
  Velero:     <none>
  Cluster:  could not restore, CustomResourceDefinition:ciliumendpoints.cilium.io already exists. Warning: the in-cluster version is different than the backed-up version
  Namespaces:
    demo:  could not restore, ConfigMap:kube-root-ca.crt already exists. Warning: the in-cluster version is different than the backed-up version
           could not restore, CiliumEndpoint:nginx-demo-bf7c6d495-cc5zr already exists. Warning: the in-cluster version is different than the backed-up version

Backup:  backup-default

Namespaces:
  Included:  all namespaces found in the backup
  Excluded:  <none>

Resources:
  Included:        *
  Excluded:        nodes, events, events.events.k8s.io, backups.velero.io, restores.velero.io, resticrepositories.velero.io, csinodes.storage.k8s.io, volumeattachments.storage.k8s.io, backuprepositories.velero.io
  Cluster-scoped:  auto

Namespace mappings:  <none>

Label selector:  <none>

Or label selector:  <none>

Restore PVs:  auto

CSI Snapshot Restores: <none included>

Existing Resource Policy:   <none>
ItemOperationTimeout:       4h0m0s

Preserve Service NodePorts:  auto

Uploader config:


HooksAttempted:   0
HooksFailed:      0
rke2-bbb-pool1-xc5q8-j55dw:~ # kubectl get ns | grep -i demo
demo                          Active   65s
rke2-bbb-pool1-xc5q8-j55dw:~ # kubectl -n demo get pods,svc
NAME                             READY   STATUS    RESTARTS   AGE
pod/nginx-demo-bf7c6d495-cc5zr   1/1     Running   0          73s

NAME                 TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
service/nginx-demo   NodePort   10.43.49.28   <none>        80:31559/TCP   72s
rke2-bbb-pool1-xc5q8-j55dw:~ #
```
