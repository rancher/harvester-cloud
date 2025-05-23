# How to create resources

- Copy `./terraform.tfvars.example` to `./terraform.tfvars`
- Edit `./terraform.tfvars`
  - Update the required variables:
    - `harvester_url` to specify the URL of the Harvester cluster API
    - `kubeconfig_file_path` to specify the full path to the Kubeconfig file, which is required to authenticate with the Harvester cluster
    - `kubeconfig_file_name` to specify the name of the Kubeconfig file used to access the Harvester cluster

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
