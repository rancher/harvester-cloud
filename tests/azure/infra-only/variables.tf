variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'harv-cloud-infra-test'."
  type        = string
  default     = "harv-cloud-infra-test"
}

variable "subscription_id" {
  description = "Specifies the Azure Subscription ID that will contain all created resources. Default is 'harv-cloud-infra-test'."
  type        = string
  default     = "harv-cloud-infra-test"
}
