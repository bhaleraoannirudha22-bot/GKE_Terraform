
# Setting up the Terraform Remote Backend (GCS)

This document explains the manual steps required to set up the Google Cloud Storage (GCS) bucket for your Terraform remote state.

## 1. Create the GCS Bucket

You need a GCS bucket to store your Terraform state files. You can create one using the `gsutil` command-line tool.

**Important:** Bucket names must be globally unique.

1.  **Choose a unique name for your bucket.** We recommend something like `<your-project-id>-tfstate`.

2.  **Create the bucket:**

    ```bash
    gsutil mb -p your-gcp-project-id gs://your-terraform-state-bucket
    ```

    Replace `your-gcp-project-id` with your GCP project ID and `your-terraform-state-bucket` with the unique name you chose.

3.  **Enable versioning on the bucket.** This is crucial for recovering from accidental state file deletions or modifications.

    ```bash
    gsutil versioning set on gs://your-terraform-state-bucket
    ```

## 2. Update `backend.tf`

Once you have created the bucket, open the `gke-terraform-project/backend.tf` file and replace `your-terraform-state-bucket` with the name of the bucket you just created.

```terraform
terraform {
  backend "gcs" {
    bucket  = "your-terraform-state-bucket" # Replace with your bucket name
    prefix  = "gke-cluster"
  }
}
```

## 3. Initialize the Backend

After updating `backend.tf`, you can initialize the backend by running the following command in the `gke-terraform-project` directory:

```bash
terraform init
```

Terraform will prompt you to copy your existing state to the new backend. Type `yes` to confirm.

Your Terraform state will now be stored securely and remotely in the GCS bucket.
