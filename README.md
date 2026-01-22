# harvester-cloud
A project for deploying Harvester on cloud providers instead of bare-metal infrastructure.

## Why?
To make it easy for anyone to spin up a Harvester environment for labs, testing, and basic PoCs.

:warning: **Not intended for production use.**

## How the repository is structured

```console
.
├── modules/
│   └── ...
├── projects/
│   └── ...
├── docs/
│   └── ...
└── # images/, tests/, LICENSE, etc.
```

The `modules/` directory contains templates for deploying VMs on different cloud providers (Google Cloud, Microsoft Azure, and DigitalOcean), along with all necessary scripts to configure Harvester.

The `projects/` directory combines modules to create different deployment recipes based on specific use cases. For example, you can deploy a 3-node Harvester cluster on Google Cloud VMs or, given an existing Harvester cluster, deploy images, networks, and additional VMs.

#### What does the `docs/` folder contain?

- [Terraform CLI preparatory steps](https://github.com/rancher/harvester-cloud/blob/main/docs/TERRAFORM.md)
- [OpenTofu CLI preparatory steps](https://github.com/rancher/harvester-cloud/blob/main/docs/OPENTOFU.md)
- [Infrastructure estimated costs](https://github.com/rancher/harvester-cloud/blob/main/docs/INFRASTRUCTURE_ESTIMATED_COSTS.md)
- [Harvester cluster deployment process](https://github.com/rancher/harvester-cloud/blob/main/docs/HARVESTER_DEPLOYMENT_PROCESS.md)
- [Performance analyses](https://github.com/rancher/harvester-cloud/blob/main/docs/PERFORMANCE.md)
- [Microsoft Azure known issues](https://github.com/rancher/harvester-cloud/blob/main/docs/AZURE_KNOWN_ISSUES.md)
- [How to create a basic Harvester VM and access it via SSH from the local CLI](https://github.com/rancher/harvester-cloud/blob/main/docs/VM_SETUP_AND_SSH_LOGIN.md)
- [How to create a downstream K8s cluster from Rancher using the Harvester Cloud Provider](https://github.com/rancher/harvester-cloud/blob/main/docs/CREATE_DOWNSTREAM_CLUSTER.md)
- [How to perform an upgrade in an air-gapped Harvester cluster](https://github.com/rancher/harvester-cloud/blob/main/docs/AIR_GAPPED_UPGRADE_PROCESS.md)
- [Implement Cross-Cluster Kubernetes Disaster Recovery with Rancher using Harvester (harvester-cloud) as Cloud Provider](https://github.com/rancher/harvester-cloud/blob/main/docs/CROSS_CLUSTER_K8S_DR.md)

## How to get started with the various projects

- [Google](https://github.com/rancher/harvester-cloud/blob/main/projects/google-cloud/README.md)
- [Azure](https://github.com/rancher/harvester-cloud/blob/main/projects/azure/README.md)
- [DigitalOcean](https://github.com/rancher/harvester-cloud/blob/main/projects/digitalocean/README.md)
- Harvester Operations:
  - [Image creation](https://github.com/rancher/harvester-cloud/blob/main/projects/harvester-ops/image-creation/README.md)
  - [Network creation](https://github.com/rancher/harvester-cloud/blob/main/projects/harvester-ops/network-creation/README.md)
  - [VM pool creation](https://github.com/rancher/harvester-cloud/blob/main/projects/harvester-ops/vm-pool-creation/README.md)
