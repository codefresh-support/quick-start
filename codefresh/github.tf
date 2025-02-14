resource "github_repository" "codefresh_isc" {
  name        = "codefresh-isc"
  description = "Codefresh Internal Shared Configurations"
  visibility  = "private"
  auto_init   = true
}

resource "github_repository" "codefresh_apps" {
  name        = "codefresh-apps"
  description = "Codefresh Git Source for Applications"
  visibility  = "private"
  auto_init   = true
}

resource "github_repository_file" "guestbook" {
  repository          = github_repository.codefresh_apps.name
  commit_message      = "[Terraform] Added Guestbook Application"
  overwrite_on_create = true
  file                = "apps/guestbook.yaml"

  content = file("${path.module}/templates/guestbook.yaml")
}

resource "github_repository_file" "git_source" {
  repository          = github_repository.codefresh_isc.name
  commit_message      = "[Terraform] Add Git Source Application"
  overwrite_on_create = true
  file                = "resources/${minikube_cluster.demo_cluster.cluster_name}/default-gitsource.yaml"

  content = templatefile("${path.module}/templates/default-gitsource.yaml", {
    repoUrl    = github_repository.codefresh_apps.http_clone_url,
    repoPath   = "apps"
    namespace  = helm_release.codefresh_gitops_runtime.namespace
    repoBranch = "main"
  })

}

resource "github_repository_file" "in_cluster" {
  repository          = github_repository.codefresh_isc.name
  commit_message      = "[Terraform] Update In-Cluster Application"
  overwrite_on_create = true
  file                = "runtimes/${minikube_cluster.demo_cluster.cluster_name}/in-cluster.yaml"

  content = templatefile("${path.module}/templates/in-cluster.yaml", {
    repoUrl     = github_repository.codefresh_isc.http_clone_url,
    runtimeName = minikube_cluster.demo_cluster.cluster_name
    namespace   = helm_release.codefresh_gitops_runtime.namespace
  })

}
