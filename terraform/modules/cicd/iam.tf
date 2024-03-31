# IAM CodePipeline
resource "aws_iam_role" "codepipeline" {
  name                 = "${var.app_name}-codepipeline"
  assume_role_policy   = data.aws_iam_policy_document.codepipeline.json
}

data "aws_iam_policy_document" "codepipeline" {
   statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  } 
}

resource "aws_iam_policy" "codepipeline" {
  name        = "${var.app_name}-codepipeline"
  description = "Allow Codepipeline deployments"
  policy      = data.aws_iam_policy_document.codepipeline2.json
}

resource "aws_iam_role_policy_attachment" "codepipeline" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.codepipeline.arn
}

data "aws_iam_policy_document" "codepipeline2" {
  statement {
    effect = "Allow"

    actions = [
      "s3:*"
    ]

    resources = [
      "arn:aws:s3:::*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:StartBuild",
      "codebuild:StopBuild",
      "codebuild:BatchGetBuilds"
    ]

    resources = ["arn:aws:codebuild:us-east-1:*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "codestar-connections:UseConnection"
    ]

    resources = ["arn:aws:codestar-connections:*"]
  }

}

# IAM CodeBuild
resource aws_iam_role codebuild {
  name                 = "${var.app_name}-codebuild"
  assume_role_policy   = data.aws_iam_policy_document.codebuild.json
}

data "aws_iam_policy_document" "codebuild" {
   statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  } 
}

resource aws_iam_policy codebuild {
  name        = "${var.app_name}-codebuild"
  description = "Allow codebuild deployments"
  policy      = data.aws_iam_policy_document.codebuild2.json
}

resource aws_iam_role_policy_attachment codebuild {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.codebuild.arn
}

data aws_iam_policy_document codebuild2 {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
      "ec2:CreateNetworkInterfacePermission"
    ]

    resources = ["arn:aws:logs:us-east-1:*","arn:aws:ec2:us-east-1:*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:*"
    ]

    resources = [
      "arn:aws:s3:::*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:UpdateReportGroup",
      "codebuild:ListReportsForReportGroup",
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:ListReports",
      "codebuild:DeleteReport",
      "codebuild:ListReportGroups",
      "codebuild:BatchPutTestCases",
      "codebuild:ImportSourceCredentials"
    ]

    resources = [
      "arn:aws:codebuild:*"
    ]
  }
  statement {
    effect = "Allow"

    actions = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage"
    ]

    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"

    actions = [
        "secretsmanager:GetSecretValue*"
    ]

    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"

    actions = [
        "eks:*"
    ]

    resources = [
      "*"
    ]
  }
}