variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'harvcloudinfratest'."
  type        = string
  default     = "harvcloudinfratest"
}

variable "project_id" {
  description = "Specifies the Google Project ID that will contain all created resources. Default is 'harvcloudinfratest'."
  type        = string
  default     = "harvcloudinfratest"
}
