
terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  cloud {
    organization = "live-beach-network"

    workspaces {
      name = "aks-runners"
    }
  }
}


provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}





resource "azurerm_resource_group" "arc-rg" {
  name     = var.resource_group_name
  location = var.location



}


resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  location            = azurerm_resource_group.arc-rg.location
  resource_group_name = azurerm_resource_group.arc-rg.name
  address_space       = ["10.0.0.0/16"]


}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.arc-rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}




resource "azurerm_log_analytics_workspace" "log-workspace" {
  name                = "DefaultWorkspace"
  location            = var.location
  resource_group_name = azurerm_resource_group.arc-rg.name
  sku                 = "PerGB2018"
}

resource "azurerm_kubernetes_cluster" "arc-cluster" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.arc-rg.location
  resource_group_name = azurerm_resource_group.arc-rg.name
  dns_prefix          = "${var.aks_cluster_name}-dns"

  identity {
    type = "SystemAssigned"
  }


  default_node_pool {
    name           = "agentpool"
    node_count     = 1
    vm_size        = "Standard_B2s"
    os_disk_size_gb = 32
    vnet_subnet_id = azurerm_subnet.subnet.id
    type = "VirtualMachineScaleSets"
    min_count = 1
    max_count = 5
    enable_auto_scaling = true


  }

 
    


  

  network_profile {
    network_plugin     = "kubenet"
    load_balancer_sku  = "standard"
    outbound_type      = "loadBalancer"
    pod_cidr           = "10.244.0.0/16"
    service_cidr       = "10.2.0.0/16"
    dns_service_ip     = "10.2.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }
}

