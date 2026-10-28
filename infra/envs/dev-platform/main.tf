data "terraform_remote_state" "dev" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = var.dev_state_key
    region = var.region
  }
}

# Short-lived tokens. The AWS CLI on this machine refreshes the token; the
# Helm provider does not store a long-lived kubeconfig.
provider "helm" {
  kubernetes = {
    host                   = data.terraform_remote_state.dev.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.dev.outputs.cluster_certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        data.terraform_remote_state.dev.outputs.cluster_name,
        "--region",
        var.region,
      ]
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "3.6.2"
  namespace  = "kube-system"

  timeout = 600
  wait    = true

  values = [
    templatefile("${path.module}/templates/aws-lb-controller.yaml.tftpl", {
      cluster_name = data.terraform_remote_state.dev.outputs.cluster_name
      region       = data.terraform_remote_state.dev.outputs.region
      vpc_id       = data.terraform_remote_state.dev.outputs.vpc_id
      role_arn     = data.terraform_remote_state.dev.outputs.lb_controller_role_arn
    })
  ]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "10.11.6"
  namespace        = "argocd"
  create_namespace = true

  timeout = 900
  wait    = true

  # The values file lives next to the Application manifest so a helm install
  # by hand and this release install the same Argo CD.
  values = [file("${path.module}/../../../deploy/argocd/values.yaml")]

  depends_on = [helm_release.aws_load_balancer_controller]
}
