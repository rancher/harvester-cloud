variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'harv-cloud-infra-test'."
  type        = string
  default     = "harv-cloud-infra-test"
}

variable "do_token" {
  description = "DigitalOcean API token used to deploy the infrastructure. Default is 'harv-cloud-infra-test'."
  type        = string
  default     = "harv-cloud-infra-test"
}
