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
  file                = "resources/runtimes/${minikube_cluster.demo_cluster.cluster_name}/default-gitsource.yaml"

  content = templatefile("${path.module}/templates/default-gitsource.yaml", {
    gitsource_repo_url    = github_repository.codefresh_apps.http_clone_url,
    gitsource_repo_path   = "apps"
    gitsource_namespace   = helm_release.codefresh_gitops_runtime.namespace
    gitsource_repo_branch = "main"
  })

}
