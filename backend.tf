# --- Terraform Remote Backend Configuration ---
# This file moves your state from your local computer to AWS S3.
# This ensures your state is:
# 1. Secured (Encrypted at rest)
# 2. Shared (Accessible for CI/CD or other team members)
# 3. Persistent (Won't be lost if you delete your local folder)

terraform {
  backend "s3" {
    bucket  = "mx-project-terraform-state" # Change to a unique bucket name
    key     = "dev-staging/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    # dynamodb_table = "terraform-lock" # Commented out due to schema mismatch (Needs Partition Key: LockID)
    use_lockfile = false
  }
}
