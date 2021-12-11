########################
### VPC Flow Logging ###
########################

resource "random_string" "this" {
  upper   = false
  lower   = true
  number  = false
  special = false
  length  = 4
}

resource "aws_flow_log" "this" {
  iam_role_arn    = aws_iam_role.this.arn
  traffic_type    = "ALL"
  log_destination = aws_cloudwatch_log_group.this.arn
  vpc_id          = var.vpc_id
}

#tfsec:ignore:aws-cloudwatch-log-group-customer-key
resource "aws_cloudwatch_log_group" "this" {
  name = "${var.resource_name_prefix}-vpc-flowlogs-${random_string.this.result}"
}

resource "aws_iam_role" "this" {
  name_prefix        = "vpc-flow-log-role-"
  assume_role_policy = data.aws_iam_policy_document.flow_log_cloudwatch_assume_role.json
}

data "aws_iam_policy_document" "flow_log_cloudwatch_assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "vpc_flow_log_cloudwatch" {
  statement {
    sid    = "AWSVPCFlowLogsPushToCloudWatch"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = ["*"] #tfsec:ignore:aws-iam-no-policy-wildcards
  }
}

resource "aws_iam_role_policy_attachment" "vpc_flow_log_cloudwatch" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.vpc_flow_log_cloudwatch.arn
}

resource "aws_iam_policy" "vpc_flow_log_cloudwatch" {
  name_prefix = "vpc-flow-log-to-cloudwatch-"
  policy      = data.aws_iam_policy_document.vpc_flow_log_cloudwatch.json
}

