# Separate state from infra/envs/dev. The Helm provider has to talk to the
# Kubernetes API, and that API does not exist until the dev stack has finished.
# Keeping the charts in their own state means `terraform plan` on the cluster
# does not need a live API server, and a chart upgrade cannot refresh the VPC.
terraform {
  backend "s3" {}
}
