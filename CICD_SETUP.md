

# Setting up the CI/CD Pipeline (GitHub Actions)

This document explains how to set up the necessary secrets in GitHub to allow the CI/CD pipeline to deploy your Terraform infrastructure.

## 1. Create a Google Cloud Service Account

The CI/CD pipeline needs a Google Cloud Service Account to authenticate with Google Cloud and create resources on your behalf.

1.  **Create a Service Account:**

    ```bash
    gcloud iam service-accounts create terraform-deployer --display-name "Terraform Deployer"
    ```

2.  **Grant the Service Account the necessary roles.** For this project, the `Editor` role is sufficient, but for production environments, you should grant more granular permissions.

    ```bash
    gcloud projects add-iam-policy-binding your-gcp-project-id \
      --member "serviceAccount:terraform-deployer@your-gcp-project-id.iam.gserviceaccount.com" \
      --role "roles/editor"
    ```

3.  **Create a JSON key for the Service Account:**

    ```bash
    gcloud iam service-accounts keys create terraform-deployer.json \
      --iam-account "terraform-deployer@your-gcp-project-id.iam.gserviceaccount.com"
    ```

    This will download a JSON file containing the key to your local machine.

## 2. Add the Service Account Key to GitHub Secrets

You need to add the content of the JSON key file as a secret in your GitHub repository.

1.  **Open your GitHub repository** and go to `Settings` > `Secrets` > `Actions`.

2.  **Click `New repository secret`.**

3.  **Name the secret `GCP_SA_KEY`.**

4.  **Copy the entire content of the `terraform-deployer.json` file** and paste it into the `Value` field.

5.  **Click `Add secret`.**

## 3. Configure the Production Environment

The pipeline uses a GitHub Environment called `production` to protect the deployment to your production environment.

1.  **Open your GitHub repository** and go to `Settings` > `Environments`.

2.  **Click `New environment`.**

3.  **Name the environment `production`** and click `Configure environment`.

4.  **(Optional) Add protection rules.** You can configure rules such as requiring a reviewer to approve deployments to this environment.

Now your CI/CD pipeline is ready to go. When you push to the `main` branch, the pipeline will run `terraform plan`, and if the plan is successful, it will create a deployment that needs to be approved before `terraform apply` is run.
