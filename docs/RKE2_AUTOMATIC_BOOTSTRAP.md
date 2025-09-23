# Harvester Configuration Bootstrapping Items Through RKE2 Manifests

It is possible to customize the Harvester configuration in such a way that elements can be bootstrapped upon cluster creation directly from written manifest files.  So after the install of the cluster the underlying [RKE2 Server Auto Deploying Manifests](https://docs.rke2.io/advanced#auto-deploying-manifests) start being fulfilled.

# Brief Example of Harvester Virtual Machine Images Being Pulled Down At Cluster Boot
- in this small example of customization Harvester VirtualMachineImage(s) are built into a manifest file in the directory of `/var/lib/rancher/rke2/server/manifests`
- we'll be in this example acquiring 3 distinct Ubuntu Cloud Images (Jammy, Focal, & Noble) and having each image be tied to the `harvester-public` namespace and also tied to the default storage class, `harvester-longhorn`
- `note: this example relies on an outbound network connection being present but could be easily adopted to target an airgapped file server as well`

## With harvester.os.write_file's, /var/lib/rancher/rke2/server/manifests/ubuntu-images.yaml
```yaml
os:
  writeFiles:
    - content: |
        apiVersion: harvesterhci.io/v1beta1
        kind: VirtualMachineImage
        metadata:
          annotations:
            harvesterhci.io/storageClassName: "harvester-longhorn"
            field.cattle.io/description: "Jammy Cloud Image Downloaded Current"
          name: jammy-cloudimg-amd64
          namespace: harvester-public
          labels:
            harvesterhci.io/imageDisplayName: jammy-cloudimg-amd64
            harvesterhci.io/os-type: ubuntu
        spec:
          retry: 3
          pvcName: ''
          pvcNamespace: ''
          checksum: ''
          description: 'Jammy Cloud Image Downloaded Current'
          storageClassParameters:
            migratable: 'true'
            numberOfReplicas: '3'
            staleReplicaTimeout: '30'
          displayName: jammy-cloudimg-amd64
          sourceType: download
          url: "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
        ---
        apiVersion: harvesterhci.io/v1beta1
        kind: VirtualMachineImage
        metadata:
          annotations:
            harvesterhci.io/storageClassName: "harvester-longhorn"
            field.cattle.io/description: "Focal Cloud Image Downloaded Current"
          name: focal-cloudimg-amd64
          namespace: harvester-public
          labels:
            harvesterhci.io/imageDisplayName: focal-cloudimg-amd64
            harvesterhci.io/os-type: ubuntu
        spec:
          retry: 3
          pvcName: ''
          pvcNamespace: ''
          checksum: ''
          description: 'Focal Cloud Image Downloaded Current'
          storageClassParameters:
            migratable: 'true'
            numberOfReplicas: '3'
            staleReplicaTimeout: '30'
          displayName: focal-cloudimg-amd64
          sourceType: download
          url: "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
        ---
        apiVersion: harvesterhci.io/v1beta1
        kind: VirtualMachineImage
        metadata:
          annotations:
            harvesterhci.io/storageClassName: "harvester-longhorn"
            field.cattle.io/description: "Noble Cloud Image Downloaded Current"
          name: noble-cloudimg-amd64
          namespace: harvester-public
          labels:
            harvesterhci.io/imageDisplayName: noble-cloudimg-amd64
            harvesterhci.io/os-type: ubuntu
        spec:
          retry: 3
          pvcName: ''
          pvcNamespace: ''
          checksum: ''
          description: 'Noble Cloud Image Downloaded Current'
          storageClassParameters:
            migratable: 'true'
            numberOfReplicas: '3'
            staleReplicaTimeout: '30'
          displayName: noble-cloudimg-amd64
          sourceType: download
          url: "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
      path: /var/lib/rancher/rke2/server/manifests/ubuntu-images.yaml
      owner: root

```

# Brief Example of Harvester User Data Cloud-Configs Being Created at Cluster First Boot
- in this other example of a bootstrapped configuration on Harvester via the underlying [RKE2 Server Auto Deploying Manifests](https://docs.rke2.io/advanced#auto-deploying-manifests) we'll create cloud-config user data configmaps that live in the `harvester-public` namespace
- we'll build two cloud-configs, both user-data based, both targetting what would be an Ubuntu cloud-image distro:
  - one cloud-config will be built that could be used to automatically install & configure Docker for the `ubuntu` cloud user
  - the other cloud-config will be built that could just install a few small packages & qemu-guest-agent service enablement

## With harvester.os.write_file's, /var/lib/rancher/rke2/server/manifests/basic-cloud-configs.yaml

```yaml
os:
  writeFiles:
    - content: |
        apiVersion: v1
        data:
          cloudInit: |-
            #cloud-config
            password: password
            chpasswd:
              expire: false
            ssh_pwauth: true
            package_update: true
            packages:
              - apt-transport-https
              - ca-certificates
              - curl
              - cowsay
              - gnupg-agent
              - software-properties-common
              - qemu-guest-agent
            write_files:
              - path: /etc/sysctl.d/enabled_ipv4_forwarding.conf
                content: |
                  net.ipv4.conf.all.forwarding=1
            groups:
              - docker
            runcmd:
              - - systemctl
                - enable
                - --now
                - qemu-guest-agent.service
              - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
              - add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              - apt-get update -y
              - apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
              - systemctl start docker
              - systemctl enable docker
            system_info:
              default_user:
                groups: [docker]
        kind: ConfigMap
        metadata:
          name: docker-buntu
          namespace: harvester-public
          labels:
            harvesterhci.io/cloud-init-template: user
          annotations:
            field.cattle.io/description: docker cloud-config
        ---
        apiVersion: v1
        data:
          cloudInit: |-
            #cloud-config
            password: password
            chpasswd:
              expire: false
            ssh_pwauth: true
            package_update: true
            packages:
              - apt-transport-https
              - ca-certificates
              - curl
              - cowsay
              - gnupg-agent
              - software-properties-common
              - qemu-guest-agent
            runcmd:
              - - systemctl
                - enable
                - --now
                - qemu-guest-agent.service
        kind: ConfigMap
        metadata:
          name: ubuntu-base
          namespace: harvester-public
          labels:
            harvesterhci.io/cloud-init-template: user
          annotations:
            field.cattle.io/description: ubuntu base user is ubuntu cloud-config
      path: /var/lib/rancher/rke2/server/manifests/basic-cloud-configs.yaml
      owner: root
```


# Bootstrapping RKE2 Manifests through Harvester Configuration Customization Wrap Up
- those two examples highlighting some customization via the `os.writeFiles` list that lend themselves to being another tool to more quickly bootstrap content into the Harvester cluster at Boot
- things can be combined or adjusted in different ways to quickly scaffold out content in a more automated fashion through the rke2/server/manifests folder so that when Harvester cluster is up those items are being worked on

# Big "Gotchya" With Custom RKE2 Manifests For Harvester Cluster Configuration
- the biggest **"gotchya"**, is that if a user wants to **permanently** remove the items built by let's say `basic-cloud-configs.yaml` the user would need to do the following:
  - delete the `ubuntu-base` cloud-config user data from `harvester-public` namespace
  - delete the `docker-buntu` cloud-config user data from `harvester-public` namespace
  - ensure that `/var/lib/rancher/rke2/server/manifests/basic-cloud-configs.yaml` is deleted, **as if the manifest in the rke2/server/manifests is not cleaned up, then even if in Harvester those items are removed, upon node reboot, the manifests would be re-applied and the cloud-configs both would be built again**