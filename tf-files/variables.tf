variable "subscription_id" {
  description = "Azure subscription ID"
  
}

variable "resource_group_name" {
  description = "Resource group for the AKS cluster"
}

variable "aks_cluster_name" {
  description = "AKS cluster name"

}

variable "location" {
  description = "Azure region where the resources will be created"

}

variable "aks_version" {
  description = "Kubernetes version for the AKS cluster"
  default     = "1.25.6"
}

variable "tenant_id" {}

variable "client_secret" {}

variable "client_id" {}

