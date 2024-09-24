resource "minikube_cluster" "demo_cluster" {
  driver       = "docker"
  cluster_name = "codefresh-demo"
  cpus         = 4
  memory       = 8192

  addons = [
    "default-storageclass",
    "storage-provisioner"
  ]

}
