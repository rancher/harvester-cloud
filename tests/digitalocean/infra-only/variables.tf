variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'harvcloudinfratest'."
  type        = string
  default     = "harvcloudinfratest"
}

variable "do_token" {
  description = "DigitalOcean API token used to deploy the infrastructure. Default is 'harvcloudinfratest'."
  type        = string
  default     = "harvcloudinfratest"
}
