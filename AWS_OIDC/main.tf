
# Get the latest TLS cert from GitHub to authenticate their requests
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

# Create the OIDC Provider in the AWS Account
resource "aws_iam_openid_connect_provider" "github_actions_provider" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

# Create an IAM Role used by Actions Runners
resource "aws_iam_role" "gha_oidc_role" {
  name = "gha_oidc_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${aws_iam_openid_connect_provider.github_actions_provider.arn}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com",
          },
          "StringLike" : {
            "token.actions.githubusercontent.com:sub" : ["repo:nihalm97/terrafor:*"]
          }
        }
      }
    ]
  })
}

# Attach policies to role
resource "aws_iam_role_policy" "gha_oidc_terraform_permissions" {
  name = "gha_oidc_terraform_permissions"
  role = aws_iam_role.gha_oidc_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sns:*",
          "lambda:*",
          "iam:*",
          "s3:*",
          "sts:AssumeRoleWithWebIdentity",
          "sts:AssumeRole"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# Needed for adding to your Github Action
output "role_arn" {
  value = aws_iam_role.gha_oidc_role.arn
}