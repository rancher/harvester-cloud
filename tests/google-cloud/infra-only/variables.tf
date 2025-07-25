variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'harv-cloud-infra-test'."
  type        = string
  default     = "harv-cloud-infra-test"
}

variable "project_id" {
  description = "Specifies the Google Project ID that will contain all created resources. Default is 'harv-cloud-infra-test'."
  type        = string
  default     = "harv-cloud-infra-test"
}
