# 1. Configures the master OpenID Connect handshake root certificate authority
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://githubusercontent.com"
  client_id_list  = ["://amazonaws.com"]
  thumbprint_list = ["1c58a3a8518e8759bf075b76b750d4f2df264fcd"] # Official GitHub thumbprint
}

# 2. Creates the secure IAM Role that GitHub Actions will temporarily assume
resource "aws_iam_role" "github_actions" {
  name = "github-actions-eks-deployer"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringEquals = {
            "://githubusercontent.com:aud" = "://amazonaws.com"
          }
          StringLike = {
            # STRICT GUARD: Only allows your specific repository to assume this role!
            "://githubusercontent.com:sub" = "repo:pyaephyo47/eks-portfolio:*"
          }
        }
      }
    ]
  })
}

# 3. Attaches full administrative permissions to this role for cluster orchestration
resource "aws_iam_role_policy_attachment" "admin_attach" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# 4. Outputs the exact configuration link string you will need for GitHub
output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions.arn
  description = "Copy this ARN string and save it to your GitHub Actions configuration file!"
}

