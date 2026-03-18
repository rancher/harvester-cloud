# Terraform | Amazong Web Services - Preparatory steps

In order for Terraform to run operations on your behalf, you must [install and configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

## Example

#### macOS installation and setup

```bash
brew update && brew install awscli
```

```bash
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_SESSION_TOKEN=""
```

##### It is also possible to add the profile to the AWS credentials file ~/.aws/credentials

```bash
aws configure
```
