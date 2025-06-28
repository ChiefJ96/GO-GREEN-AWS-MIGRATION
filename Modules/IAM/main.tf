// modules/iam/main.tf

######################
# IAM GROUPS
######################

resource "aws_iam_group" "sysadmin" {
  name = "SysAdmin"
}

resource "aws_iam_group" "dbadmin" {
  name = "DBAdmin"
}

resource "aws_iam_group" "monitor" {
  name = "Monitor"
}

######################
# IAM POLICIES
######################

data "aws_iam_policy_document" "sysadmin_policy" {
  statement {
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "sysadmin" {
  name        = "SysAdminPolicy"
  description = "Full access to everything"
  policy      = data.aws_iam_policy_document.sysadmin_policy.json
}

resource "aws_iam_group_policy_attachment" "sysadmin_attach" {
  group      = aws_iam_group.sysadmin.name
  policy_arn = aws_iam_policy.sysadmin.arn
}

######################
# EC2 ROLE FOR S3 ACCESS
######################

data "aws_iam_policy_document" "ec2_s3_access" {
  statement {
    actions   = ["s3:PutObject", "s3:GetObject"]
    resources = ["arn:aws:s3:::gogreen-documents/*"]
  }
}

resource "aws_iam_role" "ec2_s3_role" {
  name               = "EC2toS3IAMRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_s3_policy" {
  name   = "EC2S3Policy"
  policy = data.aws_iam_policy_document.ec2_s3_access.json
}

resource "aws_iam_role_policy_attachment" "ec2_s3_attach" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.ec2_s3_policy.arn
}
