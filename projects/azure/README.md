# How to create resources

- Copy `./terraform.tfvars.exmaple` to `./terraform.tfvars`
- Edit `./terraform.tfvars`
  - Update the required variables:
    - `prefix` to give the resources an identifiable name (e.g., your initials or first name)
    - `azure_subscription` to specify in which Azure subscription the resources will be created
    - `region` to specify the Azure region where resources will be created
    - `harvester_node_count` to specify the number of Harvester nodes to create (1 or 3)
    - `harvester_cluster_size` To specify resources of Harvester hosts. (Small -> 8CPUs/32GB or medium -> 16CPUs/64GB)
- Make sure you are logged into your Azure account from your local Terminal. See the preparatory steps [here](../../modules/azure/README.md).

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

## How to access Azure VMs

#### Run the following command

```bash
ssh -oStrictHostKeyChecking=no -i <PREFIX>-ssh_private_key.pem sles@<PUBLIC_IPV4>
```

## How to access Harvester Nested VMs

#### Run the following command within Azure VM where harvester is running

```bash
ssh rancher@<NESTED_VM_IPV4> # The password can be obtained from variable harvester_password or from join/create_cloud_config.yaml file in the current folder
```

# DEMOSTRATION 1 - Cluster Harvester with minimal possible configuration ("small" size)

#### Configure the terraform.tfvars file with the minimum necessary configurations

```console
$ cat terraform.tfvars
prefix               = "jlagos"
azure_subscription   = "<Subscription-id>"
region               = "spaincentral"
harvester_node_count = 3
```

#### Demonstration of applying Terraform files until accessing the Harvester UI

![](../../images/GCP_PROJ_README_1.png)
![](../../images/GCP_PROJ_README_2.png)
![](../../images/GCP_PROJ_README_3.png)
![](../../images/GCP_PROJ_README_4.png)
![](../../images/GCP_PROJ_README_5.png)

#### How to log in via SSH into the Azure Cloud VM

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
prefix                 = "jlagos"
region                 = "spaincentral"
harvester_node_count   = 3
harvester_cluster_size = "small"
azure_subscription     = "<subscription-id>"
rancher_api_url        = "<RANCHER_URL>"        # https://rancher.example.com
rancher_access_key     = "<RANCHER_ACCESS_KEY>" # token-abcde
rancher_secret_key     = "<RANCHER_SECRET_KEY>" # abcdefghijklmnopqrstuvwxyz
rancher_insecure       = true
```

#### Post-deployment checks

##### Harvester UI

![](../../images/GCP_PROJ_README_11.png) 

##### Rancher UI

![](../../images/GCP_PROJ_README_12.png)

**PS: The Rancher cluster was created on an RKE2 Kubernetes cluster on Google Cloud infrastructure. To replicate the scenario, you can take a look [here](https://github.com/rancher/tf-rancher-up/tree/main/recipes/upstream/google-cloud/rke2).**
