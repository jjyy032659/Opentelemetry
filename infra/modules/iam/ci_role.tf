# Pushes the ad image and nothing else. GetAuthorizationToken is the one
# ECR action AWS does not let you scope to a single repository.
data "aws_iam_policy_document" "ad_ci" {
  statement {
    sid       = "EcrAuth"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "EcrPush"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = [var.ecr_repository_arn]
  }
}

resource "aws_iam_role" "ad_ci" {
  name               = "${var.project}-${var.environment}-gha-ad-ci"
  assume_role_policy = data.aws_iam_policy_document.github_trust["ad_ci"].json
  description        = "GitHub Actions on main may push the ad image. It cannot change infrastructure."
}

resource "aws_iam_role_policy" "ad_ci" {
  name   = "ecr-push"
  role   = aws_iam_role.ad_ci.id
  policy = data.aws_iam_policy_document.ad_ci.json
}
