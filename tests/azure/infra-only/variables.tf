variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'harvcloudinfratest'."
  type        = string
  default     = "harvcloudinfratest"
}

variable "subscription_id" {
  description = "Specifies the Azure Subscription ID that will contain all created resources. Default is 'harvcloudinfratest'."
  type        = string
  default     = "harvcloudinfratest"
}
