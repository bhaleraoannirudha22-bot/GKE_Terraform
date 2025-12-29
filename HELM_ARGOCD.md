
# Integrating Helm and ArgoCD with your GKE Cluster

This document explains how to integrate Helm and ArgoCD with the GKE cluster you have created with Terraform.

## Prerequisites

*   You have successfully provisioned the GKE cluster using the provided Terraform code.
*   You have `kubectl` installed and configured to connect to your GKE cluster. You can configure this by running the following command:

    ```bash
    gcloud container clusters get-credentials $(terraform output -raw cluster_name) --region $(terraform output -raw region)
    ```

*   You have a GitHub repository to store your Kubernetes manifests and Helm charts.

## 1. Helm Integration

Helm is a package manager for Kubernetes that simplifies the process of deploying and managing applications.

### Installing the Helm CLI

Follow the official Helm documentation to install the Helm CLI on your local machine: [https://helm.sh/docs/intro/install/](https://helm.sh/docs/intro/install/)

### Using Helm to Deploy an Application

Once Helm is installed, you can use it to deploy applications (called "charts") to your GKE cluster.

Here's an example of how to deploy the `cert-manager` chart, which is often used for managing TLS certificates:

1.  **Add the cert-manager Helm repository:**

    ```bash
    helm repo add jetstack https://charts.jetstack.io
    ```

2.  **Update your local Helm chart repository cache:**

    ```bash
    helm repo update
    ```

3.  **Install the cert-manager chart:**

    ```bash
    helm install \
      cert-manager jetstack/cert-manager \
      --namespace cert-manager \
      --create-namespace \
      --version v1.10.1 \
      --set installCRDs=true
    ```

This will install `cert-manager` in a new `cert-manager` namespace on your cluster.

## 2. ArgoCD Integration

ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes. It allows you to define your desired application state in a Git repository, and ArgoCD will automatically sync your cluster to match that state.

### Installing the ArgoCD CLI

Follow the official ArgoCD documentation to install the ArgoCD CLI on your local machine: [https://argo-cd.readthedocs.io/en/stable/cli_installation/](https://argo-cd.readthedocs.io/en/stable/cli_installation/)

### Installing the ArgoCD Operator

1.  **Create a namespace for ArgoCD:**

    ```bash
    kubectl create namespace argocd
    ```

2.  **Apply the ArgoCD installation manifest:**

    ```bash
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    ```

This will deploy the ArgoCD operator and its related resources to the `argocd` namespace.

### Accessing the ArgoCD UI

By default, the ArgoCD API server is not exposed with an external IP. To access it, you can use port forwarding:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

You can then access the ArgoCD UI by visiting `https://localhost:8080` in your browser.

The initial password for the `admin` user is automatically generated and stored in a secret. You can retrieve it with the following command:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

### Using ArgoCD to Deploy an Application

ArgoCD works by tracking a Git repository for changes to your Kubernetes manifests. Here's how to set up an application in ArgoCD:

1.  **Create a Git repository** with your Kubernetes manifests. For example, you could have a repository with the following structure:

    ```
    my-app/
    ├── deployment.yaml
    ├── service.yaml
    └── ingress.yaml
    ```

2.  **Create an ArgoCD `Application` manifest.** This is a Kubernetes manifest that tells ArgoCD where your manifests are and how to deploy them.

    Create a file named `my-app-application.yaml`:

    ```yaml
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: my-app
      namespace: argocd
    spec:
      project: default
      source:
        repoURL: 'https://github.com/your-username/your-app-repo.git' # Replace with your repo URL
        path: my-app
        targetRevision: HEAD
      destination:
        server: 'https://kubernetes.default.svc'
        namespace: my-app
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
    ```

3.  **Apply the `Application` manifest:**

    ```bash
    kubectl apply -f my-app-application.yaml
    ```

ArgoCD will now monitor your Git repository and automatically apply any changes to your GKE cluster.
