terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.5.0"
    }
    codefresh = {
      source  = "codefresh-io/codefresh"
      version = "0.12.0"
    }
    minikube = {
      source  = "scott-the-programmer/minikube"
      version = "0.4.4"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
  }
  backend "local" {

  }
}

provider "github" {
  token = var.GITHUB_PAT
}

data "github_user" "current" {
  username = ""
}

provider "codefresh" {
  token = var.CF_API_KEY
}

data "codefresh_current_account" "acc" {

}

provider "helm" {
  kubernetes {
    host                   = minikube_cluster.demo_cluster.host
    client_certificate     = minikube_cluster.demo_cluster.client_certificate
    client_key             = minikube_cluster.demo_cluster.client_key
    cluster_ca_certificate = minikube_cluster.demo_cluster.cluster_ca_certificate
  }
}