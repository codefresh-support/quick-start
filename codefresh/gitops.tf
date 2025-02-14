resource "codefresh_account_gitops_settings" "gitops-settings" {
  git_provider             = "GITHUB"
  shared_config_repository = github_repository.codefresh_isc.http_clone_url
}

resource "helm_release" "codefresh_gitops_runtime" {
  name             = "codefresh-gitops"
  repository       = "oci://quay.io/codefresh"
  chart            = "gitops-runtime"
  version          = "0.16.2"
  namespace        = "cf-gitops"
  create_namespace = true
  timeout          = 600

  values = [
    yamlencode({
      global = {
        codefresh = {
          accountId = data.codefresh_current_account.acc.id
          userToken = {
            token = var.CF_API_KEY
          }
        }
        runtime = {
          name = minikube_cluster.demo_cluster.cluster_name
          gitCredentials = {
            username = data.github_user.current.login
            password = {
              value = var.GITHUB_PAT
            }
          }
        }
      }

    })
  ]

  depends_on = [codefresh_account_gitops_settings.gitops-settings]

  provisioner "local-exec" {
    command = "curl --no-progress-meter --location 'https://${data.codefresh_current_account.acc.id}-${minikube_cluster.demo_cluster.cluster_name}.tunnels.cf-cd.com/app-proxy/api/graphql' --header 'Content-Type: application/json' --header 'Authorization: ${var.CF_API_KEY}' --data '{\"operationName\": \"RegisterToGitIntegration\",\"variables\": {\"args\": {\"name\": \"default\", \"token\": \"${var.GITHUB_PAT}\", \"username\": \"${data.github_user.current.login}\" }}, \"query\": \"mutation RegisterToGitIntegration($args: RegisterToGitIntegrationArgs) {\\n  registerToGitIntegration(args: $args) {\\n    name\\n    __typename\\n  }\\n}\"}'"
  }

}
