# How to create resources

- Copy `./terraform.tfvars.example` to `./terraform.tfvars`
- Edit `./terraform.tfvars`
  - Update the required variables:
    - `prefix` to give the resources an identifiable name (e.g., your initials or first name)
    - `project_id` to specify in which Project the resources will be created
    - `region` to specify the Google region where resources will be created
    - `harvester_node_count` to specify the number of Harvester nodes to create (1 or 3)
- Make sure you are logged into your Google Account from your local Terminal. See the preparatory steps [here](../../modules/google-cloud/README.md).
- If you need to change the size of your VM, make sure you choose those with an [Intel processor](https://cloud.google.com/compute/docs/instances/nested-virtualization/overview). `libvirt` works very well on this processor family.

#### Terraform Apply

```bash
terraform init -upgrade && terraform apply -auto-approve
```

#### Terraform Destroy

```bash
terraform destroy -auto-approve
```

#### OpenTofu Apply

```bash
tofu init -upgrade && tofu apply -auto-approve
```

#### OpenTofu Destroy

```bash
tofu destroy -auto-approve
```

## How to execute `kubectl` commands to Harvester cluster

#### Run the following command

```bash
export KUBECONFIG=<PREFIX>_kube_config.yaml
```

## How to access Google VMs

#### Run the following command

```bash
ssh -oStrictHostKeyChecking=no -i <PREFIX>-ssh_private_key.pem opensuse@<PUBLIC_IPV4>
```

## How to access Harvester Nested VMs

#### Run the following command within Google VM where harvester is running

```bash
ssh rancher@<NESTED_VM_IPV4> # The password can be obtained from variable harvester_password or from join/create_cloud_config.yaml file in the current folder
```

# DEMOSTRATION 1 - Cluster Harvester with minimal possible configuration ("small" size)

#### Configure the terraform.tfvars file with the minimum necessary configurations

```console
$ cat terraform.tfvars
prefix               = "jlagos"
project_id           = "<PROJECT_ID>"
region               = "europe-west8"
harvester_node_count = 3
```

#### Demonstration of applying Terraform files until accessing the Harvester UI

![](../../images/GCP_PROJ_README_1.png)
![](../../images/GCP_PROJ_README_2.png)
![](../../images/GCP_PROJ_README_3.png)
![](../../images/GCP_PROJ_README_4.png)
![](../../images/GCP_PROJ_README_5.png)

#### How to log in via SSH into the Google Cloud VM

![](../../images/GCP_PROJ_README_6.png)

#### How to log in via SSH into nested VMs (Harvester nodes)

![](../../images/GCP_PROJ_README_7.png)

#### How to run `kubectl` commands on Harvester cluster

![](../../images/GCP_PROJ_README_8.png)

# DEMOSTRATION 2 - Cluster Harvester (with minimal possible configuration) that is automatically added to a Rancher cluster

#### Create API keys from the Rancher cluster

![](../../images/GCP_PROJ_README_9.png)
![](../../images/GCP_PROJ_README_10.png)

#### Configure the terraform.tfvars file by entering the Rancher API key

```console
$ cat terraform.tfvars
prefix               = "glovecchio"
project_id           = "<PROJECT_ID>"
region               = "europe-west8"
harvester_node_count = 3
rancher_api_url      = "<RANCHER_URL>"        # https://rancher.example.com
rancher_access_key   = "<RANCHER_ACCESS_KEY>" # token-abcde
rancher_secret_key   = "<RANCHER_SECRET_KEY>" # abcdefghijklmnopqrstuvwxyz
rancher_insecure     = true
```

#### Post-deployment checks

##### Harvester UI

![](../../images/GCP_PROJ_README_11.png) 

##### Rancher UI

![](../../images/GCP_PROJ_README_12.png)

**PS: The Rancher cluster was created on an RKE2 Kubernetes cluster on Google Cloud infrastructure. To replicate the scenario, you can take a look [here](https://github.com/rancher/tf-rancher-up/tree/main/recipes/upstream/google-cloud/rke2).**

# DEMOSTRATION 3 - Cluster Harvester with 3 additional data disks per instance

#### Configure the terraform.tfvars file with the minimum necessary configurations

```console
$ cat terraform.tfvars
prefix               = "glovecchio"
project_id           = "<PROJECT_ID>"
region               = "europe-west8"
harvester_node_count = 3
data_disk_count      = 4
```

**1 is the minimum accepted value, because it is the default disk needed for the Harvester host to function, so to have 3 more disks, the value will have to be 4.**

#### Harvester UI - Add Disks to Harvester Hosts (example for node 1)

![](../../images/GCP_PROJ_README_13.png)
![](../../images/GCP_PROJ_README_14.png)
![](../../images/GCP_PROJ_README_15.png)
![](../../images/GCP_PROJ_README_16.png)
![](../../images/GCP_PROJ_README_17.png)
