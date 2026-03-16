# Google Cloud cost analysis

The following information provides an infrastructure cost estimation for deploying Harvester on GCP using all available options in the Terraform script.

Please note that all estimated costs shown are generic approximations that have been rounded up and may not be 100% accurate, as the total price will vary depending on each specific scenario and GCP project.

| Type   | Region       |  Mode   |  Disks |  Disk Type |  Disk Size |  Required Instance | Estimated Cost per Month ($)     |
|--------|--------------|---------|--------|------------|------------|--------------------|----------------------------------|
| Small  | europe-west8 | Spot    | 1      | pd-ssd     | 350 GB     | n2-standard-16     | 250                              |
| Small  | europe-west8 | Spot    | 3      | pd-ssd     | 350 GB     | n2-standard-32     | 400                              |
| Small  | europe-west8 | Regular | 1      | pd-ssd     | 350 GB     | n2-standard-16     | 800                              |
| Small  | europe-west8 | Regular | 3      | pd-ssd     | 350 GB     | n2-standard-32     | 1500                             |
| Medium | europe-west8 | Spot    | 1      | pd-ssd     | 350 GB     | n2-standard-32     | 400                              |
| Medium | europe-west8 | Spot    | 3      | pd-ssd     | 350 GB     | n2-standard-64     | 600                              |
| Medium | europe-west8 | Regular | 1      | pd-ssd     | 350 GB     | n2-standard-32     | 1500                             |
| Medium | europe-west8 | Regular | 3      | pd-ssd     | 350 GB     | n2-standard-64     | 2800                             |

The calculations were done using the *[Google Cloud pricing calculator](https://cloud.google.com/calculator)*.

# Microsoft Azure cost analysis

The following information provides an infrastructure cost estimation for deploying Harvester on Azure using all available options in the Terraform script.

Please note that all estimated costs shown are generic approximations that have been rounded up and may not be 100% accurate, as the total price will vary depending on each specific scenario and Azure subscription.

| Type   | Region      |  Mode   |  Disks | Disk Type    |  Disk Size | Required Instance | Estimated Cost per Month ($) |
|--------|-------------|---------|--------|--------------|------------|-------------------|------------------------------|
| Small  | Europe West | Spot    | 1      | PREMIUM LRS  | 350 GB     | Standard_D16s_v5  | 250                          |
| Small  | Europe West | Spot    | 3      | PREMIUM LRS  | 350 GB     | Standard_D32s_v5  | 500                          |
| Small  | Europe West | Regular | 1      | PREMIUM LRS  | 350 GB     | Standard_D16s_v5  | 800                          |
| Small  | Europe West | Regular | 3      | PREMIUM LRS  | 350 GB     | Standard_D32s_v5  | 1650                         |
| Medium | Europe West | Spot    | 1      | PREMIUM LRS  | 350 GB     | Standard_D32s_v5  | 350                          |
| Medium | Europe West | Spot    | 3      | PREMIUM LRS  | 350 GB     | Standard_D64s_v5  | 700                          |
| Medium | Europe West | Regular | 1      | PREMIUM LRS  | 350 GB     | Standard_D32s_v5  | 1500                         |
| Medium | Europe West | Regular | 3      | PREMIUM LRS  | 350 GB     | Standard_D64s_v5  | 2850                         |

The calculations were done using the *[Microsoft Azure pricing calculator](https://azure.microsoft.com/en-us/pricing/calculator/?service=spot-advisor)*.

# DigitalOcean cost analysis

The following information provides an infrastructure cost estimation for deploying Harvester on DigitalOcean using all available options in the Terraform script.

Please note that all estimated costs shown are generic approximations that have been rounded up and may not be 100% accurate, as the total price will vary depending on each specific scenario.

| Type   | Region      |  Disks | Disk Type | Disk Size | Required Instance    | Estimated Cost per Month ($) |
|--------|-------------|--------|-----------|-----------|----------------------|------------------------------|
| Small  | Europe West | 1      | SSD       | 350 GB    | g-16vcpu-64gb-intel  | 540                          |
| Small  | Europe West | 3      | SSD       | 350 GB    | g-32vcpu-128gb-intel | 1100                         |
| Medium | Europe West | 1      | SSD       | 350 GB    | g-32vcpu-128gb-intel | 1050                         |
| Medium | Europe West | 3      | SSD       | 350 GB    | g-60vcpu-240gb-intel | 2400                         |

**Please note that on DigitalOcean it is not possible to deploy spot droplets.**

The calculations were done using the *[DigitalOcean pricing calculator](https://www.digitalocean.com/pricing/calculator)*.

# AWS cost analysis

The following information provides an infrastructure cost estimation for deploying Harvester on AWS using all available options in the Terraform script.

Please note that all estimated costs shown are generic approximations that have been rounded up and may not be 100% accurate, as the total price will vary depending on each specific scenario.

| Type   | Region         |  Mode   |  Disks | Disk Type |  Disk Size | Required Instance | Estimated Cost per Month ($) |
|--------|----------------|---------|--------|-----------|------------|-------------------|------------------------------|
| Small  | eu-central-1   | Spot    | 1      | GP3       | 350 GB     | m8i.4xlarge       | 695                          |
| Small  | eu-central-1   | Spot    | 3      | GP3       | 350 GB     | m8i.8xlarge       | 1405                         |
| Small  | eu-central-1   | Regular | 1      | GP3       | 350 GB     | m8i.4xlarge       | 940                          |
| Small  | eu-central-1   | Regular | 3      | GP3       | 350 GB     | m8i.8xlarge       | 1900                         |
| Medium | eu-central-1   | Spot    | 1      | GP3       | 350 GB     | m8i.8xlarge       | 1065                         |
| Medium | eu-central-1   | Spot    | 3      | GP3       | 350 GB     | m8i.16xlarge      | 2165                         |
| Medium | eu-central-1   | Regular | 1      | GP3       | 350 GB     | m8i.8xlarge       | 1560                         |
| Medium | eu-central-1   | Regular | 3      | GP3       | 350 GB     | m8i.16xlarge      | 3145                         |

The calculations were done using the *[AWS pricing calculator](https://calculator.aws/#/) and official AWS Rufus AI*.