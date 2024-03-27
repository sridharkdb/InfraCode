# Generate random resource group name
resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

resource "random_pet" "azurerm_kubernetes_cluster_name" {
  prefix = "cluster"
}

resource "random_pet" "azurerm_kubernetes_cluster_dns_prefix" {
  prefix = "dns"
}

provider "helm" {
  kubernetes {
    host = azurerm_kubernetes_cluster.k8s.kube_config[0].host

    client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
    client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.k8s.kube_config[0].host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate)
}
resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  name                = random_pet.azurerm_kubernetes_cluster_name.id
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = random_pet.azurerm_kubernetes_cluster_dns_prefix.id

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2_v2"
    node_count = var.node_count
  }
  linux_profile {
    admin_username = var.username

    ssh_key {
      key_data = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}

resource "helm_release" "mediawiki" {
  name       = "mediawiki"
  chart      = "./charts/mediawiki"

 depends_on = [helm_release.mysql]

}

resource "helm_release" "mysql" {
  name  = "mysql"
  chart = "./charts/mysql"
  set {
    name  = "auth.rootPassword"
    value = "SKAdmin@24"
  }
  set {
    name  = "auth.password"
    value = "twMediaWiki@24"
  }
  set {
    name  = "auth.database"
    value = "mediawiki"
  }
  set {
    name  = "auth.username"
    value = "wiki"
  }
  set {
    name  = "metrics.enabled"
    value =  true
  }
  set {
    name  = "auth.createDatabase"
    value =  true
  }
}
