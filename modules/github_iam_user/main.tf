resource "aws_iam_user" "this" {
  name = "${var.resource_name_prefix}-github-actions"
}

resource "aws_iam_user_policy" "this" {
  policy = data.aws_iam_policy_document.role_policy.json
  user   = aws_iam_user.this.name
}

data "aws_iam_policy_document" "role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus"
    ]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["ec2:TerminateInstances"]
    resources = ["*"] #tfsec:ignore:aws-iam-no-policy-wildcards
    condition {
      test     = "StringEquals"
      values   = ["true"]
      variable = "aws:ResourceTag/GitHub"
    }
  }
  statement {
    effect    = "Allow"
    actions   = ["ec2:RunInstances"]
    resources = ["*"] #tfsec:ignore:aws-iam-no-policy-wildcards

  }
  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateTags"]
    resources = ["*"] #tfsec:ignore:aws-iam-no-policy-wildcards
    condition {
      test     = "StringEquals"
      values   = ["RunInstances"]
      variable = "ec2:CreateAction"
    }
  }
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole", "sts:TagSession"]
    resources = [aws_iam_role.this.arn]
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.resource_name_prefix}-terraform-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      identifiers = [aws_iam_user.this.arn]
      type        = "AWS"
    }
    actions = ["sts:AssumeRole", "sts:TagSession"]
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.this.name
}