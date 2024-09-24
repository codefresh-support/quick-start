# Codefresh Support - Quick Start Guide

This quick start guide is designed for new Codefresh accounts or accounts with no GitOps Runtimes installed. This guide utilizes [GitHub Codespaces](https://github.com/features/codespaces), which is free for ~30 hours a month based on the settings needed, to make this guide available for users with Chromebooks, low-powered devices, tablets, and any other devices with a modern browser and internet connection.

## Prereqs

- [Codefresh](https://g.codefresh.io/) account
- [GitHub](https://github.com/) account

### Local

If you want to use your local device, below are the requirements.

- Cpus: 4
- Memory: 16GB
- [minikube](https://minikube.sigs.k8s.io/)
- [docker](https://www.docker.com/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/)
- [OpenTofu](https://opentofu.org/)
  - Can use [Terraform](https://www.terraform.io/) instead.
- [curl](https://curl.se/)

## Getting Started

1. Select ["Use this template" > "Create a new repository"](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template).
1. Once the repository is created, navigate to the settings tab.
1. Click "Secrets and variables" > Codespaces on the left side.
1. From there, we are going to add two variables.
   - `TF_VAR_CF_API_KEY`: A [Codefresh API Key](https://codefresh.io/docs/docs/administration/user-self-management/user-settings/#create-and-manage-api-keys) with All Scopes.
   - `TF_VAR_GITHUB_PAT`: A [Personal access tokens (classic)](https://github.com/settings/tokens) with the scopes of `admin:repo_hook, delete_repo, read:org, repo`.
1. Once added, navigate back to the "Code" tab.
1. Select the green "Code" button > "Codespaces" tab > "Create codespace on main."
1. Once the Codespace is up and running, open the terminal.
1. Navigate to the "codefresh" directory: `cd codefresh`.
1. Initialize the project by running `tofu init`.
1. Now we are going to apply the configuration by running `tofu apply`.
1. Type in "yes" to approve the creation of resources.
1. Once completed, everything should be up and running. For more details, refer to [Resources Being Created](#resources-being-created).

## Clean Up

To clean up the created resources, run the following command in the `./codefresh` directory. When asked to confirm, type "yes."

```shell
tofu apply --destroy
```

## Resources Being Created

The following items are resources created by the OpenTofu/Terraform code based on the file names.

### `./codefresh/classic.tf`

- A [Hybrid Pipelines Runtime](https://codefresh.io/docs/docs/installation/runner/)
- A Codefresh Project
- A Codefresh Pipeline
- A Git Pipelines Integration

### `./codefresh/github.tf`

- A repository name "codefresh-isc"
- A repository name "codefresh-apps"
- A [Git Source](https://codefresh.io/docs/docs/installation/gitops/git-sources/)
- A sample Argo CD application

### `./codefresh/gitops.tf`

- Configures the [GitOps Git Provider](https://codefresh.io/docs/docs/installation/gitops/hybrid-gitops-helm-installation/#step-2-set-up-gitops-git-provider)
- A [Hybrid GitOps Runtime](https://codefresh.io/docs/docs/installation/gitops/hybrid-gitops-helm-installation/)
- Adds a [Git Personal Token](https://codefresh.io/docs/docs/administration/user-self-management/manage-pats/) to the runtime

### `./codefresh/minikube.tf`

- a minikube kubernetes cluster

## Things to Note

The OpenTofu/Terraform codes use the local backend for their state. If the Codespace is ever destroyed, you will lose the state of the resources. You will then need to manually delete the resources it has created to use this code again. You can modify the back end in the `./codefresh/main.tf` file.
