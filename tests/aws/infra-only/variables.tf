variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'harv-cloud-infra-test'."
  type        = string
  default     = "harv-cloud-infra-test"
}

variable "certified_os_image" {
  description = "Specifies whether to use the Harvester OS image released in the GitHub repository. If set to false, the default OpenSUSE image provided by the cloud provider will be used. Default is 'false'."
  type        = bool
  default     = true
}

variable "certified_os_image_tag" {
  description = "Specifies which GitHub release to use for the Harvester OpenSUSE image. Default is 'build-5'."
  type        = string
  default     = "build-5"
  validation {
    condition     = can(regex("^build-[0-9]+$", var.certified_os_image_tag))
    error_message = "Invalid value for certified_os_image_tag. Allowed values must match the format 'build-<number>'."
  }
}
