data "aws_caller_identity" "current" {}

locals {
  github_oidc_provider_arn = (
    var.create_github_oidc_provider
    ? aws_iam_openid_connect_provider.github[0].arn
    : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
  )

  github_repo = "${var.github_owner}/${var.github_repo}"
}

# One provider per account for token.actions.githubusercontent.com. The
# thumbprints are GitHub's published root CAs. They are not secrets. IAM
# requires the field even though it also checks GitHub's own OIDC metadata.
resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_github_oidc_provider ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]
}

# Each role has its own subject list. The image role trusts only pushes to
# main. The plan role also trusts pull_request, which is the subject GitHub
# sends for a pull request workflow in this repository.
data "aws_iam_policy_document" "github_trust" {
  for_each = {
    ad_ci = [
      "repo:${local.github_repo}:ref:refs/heads/main",
    ]
    terraform_plan = [
      "repo:${local.github_repo}:pull_request",
      "repo:${local.github_repo}:ref:refs/heads/main",
    ]
  }

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.github_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = each.value
    }
  }
}
