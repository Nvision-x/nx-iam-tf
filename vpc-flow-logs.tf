# VPC Flow Logs IAM Role
resource "aws_iam_role" "vpc_flow_logs" {
  count = var.create_vpc_flow_logs_role ? 1 : 0
  name  = "nvisionx-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "nvisionx-vpc-flow-logs-role"
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  count = var.create_vpc_flow_logs_role ? 1 : 0
  name  = "nvisionx-vpc-flow-logs-policy"
  role  = aws_iam_role.vpc_flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
