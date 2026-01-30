variable "project" {
  type        = string
  description = "Project name"
}
variable "department" {
  type        = string
  description = "Department"
}

variable "environment" {
  type        = string
  description = "Environment (dev / stage / prod)"
}

variable "location" {
  type        = string
  description = "Azure region to deploy module to"
}

variable "counter" {
  type        = string
  description = "Azure region to deploy module to"
}

variable "owner_email" {
  type        = string
  description = "System owner email"
}

variable "location_short" {
  type        = string
  description = "Azure short region to deploy module to"
}

variable "cost_center" {
  type        = string
  description = "Cost Center name"
}

variable "owner" {
  type        = string
  description = "System owner"
}

variable "commit_id" {
  type        = string
  description = "Commit id"
}

variable "branch_name" {
  type        = string
  description = "branch name"
}

variable "subnet_main_address_prefixes" {
  type        = list(string)
  description = "subnet address spaces"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "vnet address spaces"
}

variable "subscription_id" {
  type        = string
  description = "subscription_id"
}
