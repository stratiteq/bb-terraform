###########
# Variables
###########
variable "applicationName" {
  default = "terraform-demo"
}

variable "resourceGroupName" {
    description = "Resource group name"
}

variable "location" {
  description = "Resource location",
  default = "West Europe"
}

variable "environmentSuffix" {
  description = "DEV, TEST etc.",
}
