# Read-only against the resources this project manages, plus the ability to
# take and release the state lock. Plan writes a lock item and reads state.
# It does not write state, and this role cannot create or delete infrastructure.
# Apply stays on your laptop.
data "aws_iam_policy_document" "terraform_plan" {
  statement {
    sid    = "ReadInfrastructure"
    effect = "Allow"
    actions = [
      "acm:Describe*",
      "acm:List*",
      "dynamodb:Describe*",
      "dynamodb:List*",
      "ec2:Describe*",
      "ecr:Describe*",
      "ecr:Get*",
      "ecr:List*",
      "eks:Describe*",
      "eks:List*",
      "elasticloadbalancing:Describe*",
      "iam:Get*",
      "iam:List*",
      "route53:Get*",
      "route53:List*",
      "s3:Get*",
      "s3:List*",
      "sts:GetCallerIdentity",
    ]
    # Most Describe and List actions do not support resource-level permissions.
    resources = ["*"]
  }

  statement {
    sid    = "ReadState"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = [
      var.state_bucket_arn,
      "${var.state_bucket_arn}/*",
    ]
  }

  statement {
    sid    = "LockState"
    effect = "Allow"
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
    ]
    resources = [var.lock_table_arn]
  }
}

resource "aws_iam_role" "terraform_plan" {
  name               = "${var.project}-${var.environment}-gha-terraform-plan"
  assume_role_policy = data.aws_iam_policy_document.github_trust["terraform_plan"].json
  description        = "GitHub Actions may plan this stack. It cannot apply it."
}

resource "aws_iam_role_policy" "terraform_plan" {
  name   = "terraform-plan"
  role   = aws_iam_role.terraform_plan.id
  policy = data.aws_iam_policy_document.terraform_plan.json
}
