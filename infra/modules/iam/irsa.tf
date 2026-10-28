# The controller's service account in kube-system exchanges a projected
# token for this role. The subject is the namespace and the service account
# name, so a different pod in the cluster cannot assume it.
data "aws_iam_policy_document" "lb_controller_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.eks_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.eks_oidc_issuer_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.eks_oidc_issuer_host}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "lb_controller" {
  name               = "${var.project}-${var.environment}-aws-lb-controller"
  assume_role_policy = data.aws_iam_policy_document.lb_controller_trust.json
  description        = "IRSA role for the AWS Load Balancer Controller."
}

# Vendored from aws-load-balancer-controller v3.6.2 so apply does not fetch
# the policy from GitHub, and so the permissions can be reviewed in this repo.
# Source: https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/v3.6.2/docs/install/iam_policy.json
resource "aws_iam_policy" "lb_controller" {
  name        = "${var.project}-${var.environment}-aws-lb-controller"
  description = "Permissions required by the AWS Load Balancer Controller."
  policy      = file("${path.module}/policies/aws-load-balancer-controller.json")
}

resource "aws_iam_role_policy_attachment" "lb_controller" {
  role       = aws_iam_role.lb_controller.name
  policy_arn = aws_iam_policy.lb_controller.arn
}
