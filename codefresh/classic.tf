resource "helm_release" "codefresh_pipelines_runtime" {
  name             = "codefresh-classic"
  repository       = "oci://quay.io/codefresh"
  chart            = "cf-runtime"
  version          = "7.5.3"
  namespace        = "cf-pipelines"
  create_namespace = true
  timeout          = 600

  values = [
    yamlencode({
      global = {
        # runtimeName    = minikube_cluster.demo_cluster.cluster_name
        agentName      = minikube_cluster.demo_cluster.cluster_name
        context        = minikube_cluster.demo_cluster.cluster_name
        accountId      = data.codefresh_current_account.acc.id
        codefreshToken = var.CF_API_KEY
      }
      monitor = {
        enabled = true
      }

    })
  ]

  depends_on = [minikube_cluster.demo_cluster]

}

resource "codefresh_project" "demo_project" {
  name = "Demo-Project"
}

resource "codefresh_pipeline" "demo_pipeline" {

  name                 = "${codefresh_project.demo_project.name}/Demo-Pipeline"
  original_yaml_string = file("./templates/demo-pipeline.yaml")

  spec {
    concurrency = 1
    runtime_environment {
      name = "${minikube_cluster.demo_cluster.cluster_name}/${helm_release.codefresh_pipelines_runtime.metadata.0.namespace}"
    }
  }
}

resource "null_resource" "create_git_integration" {
  provisioner "local-exec" {
    command = "curl --no-progress-meter --location 'https://g.codefresh.io/api/contexts?' --header 'Content-Type: application/json' --header 'Authorization: ${var.CF_API_KEY}' --data '{\"apiVersion\":\"v1\",\"kind\":\"context\",\"owner\":\"account\",\"metadata\":{\"name\":\"github-demo-${data.github_user.current.login}\"},\"spec\":{\"type\":\"git.github\",\"data\":{\"sharingPolicy\":\"AllUsersInAccount\",\"auth\":{\"type\":\"basic\",\"password\":\"${var.GITHUB_PAT}\"},\"behindFirewall\":false,\"sshClone\":false}}}'"
  }
}

resource "null_resource" "destroy_git_integration" {
  provisioner "local-exec" {
    when    = destroy
    command = "curl 'https://g.codefresh.io/api/contexts/github-demo-${self.triggers.GITHUB_USER}' -X 'DELETE' --header 'Authorization: ${self.triggers.CF_API_KEY}'"
  }

  triggers = {
    CF_API_KEY  = var.CF_API_KEY
    GITHUB_USER = data.github_user.current.login
  }
}