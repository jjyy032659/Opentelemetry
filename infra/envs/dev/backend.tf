# Partial backend. Copy backend.hcl.example to backend.hcl after the
# bootstrap stack has created the bucket and the lock table, then run:
#
#   terraform init -backend-config=backend.hcl
#
terraform {
  backend "s3" {}
}
