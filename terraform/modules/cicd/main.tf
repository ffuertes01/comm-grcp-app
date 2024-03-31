# CODEBUILD
resource "aws_codebuild_project" "build" {
  name          = "${var.app_name}-build"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 10

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = "${var.app_name}-codebuild-cache/_cache/archives"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yaml"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = var.codebuild_image
    type            = "LINUX_CONTAINER"
    privileged_mode = true
      
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.aws_account_id
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.ecr_repo_name
    }

    environment_variable {
      name  = "CLUSTER_NAME"
      value = var.cluster_name
    }

  }

  tags = {
    Name = "${var.app_name}-codebuild"
  }
}

# CODEPIPELINE
resource "aws_codepipeline" "main" {
  name = "${var.app_name}-pipeline"
  role_arn = aws_iam_role.codepipeline.arn 

  artifact_store {
    location = aws_s3_bucket.pipeline_bucket.bucket
    type = "S3"
  }

  stage {
    name = "Source"
    action {
      name = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        ConnectionArn    = var.codestar-connection
        FullRepositoryId = var.fullrepositoryid
        BranchName       = var.branch_name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name = "Build"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      input_artifacts = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version = "1"

      configuration = {
        ProjectName   = aws_codebuild_project.build.arn
        PrimarySource = "SourceArtifact"
      }

      run_order = 2
    }
  }

  tags = {
    Name = "${var.app_name}-codepipeline"
  }
}

# S3 bucket for CodePipeline artifacts
resource "aws_s3_bucket" "pipeline_bucket" {
  bucket = "${var.app_name}-pipeline-artifacts"

  tags = {
    Name = "${var.app_name}-pipeline-artifacts"
  }
}

# S3 bucket for CodeBuild cache
resource "aws_s3_bucket" "codebuild_bucket" {
  bucket = "${var.app_name}-codebuild-cache"

  tags = {
    Name = "${var.app_name}-codebuild-cache"
  }
}

# ECR Repo
resource "aws_ecr_repository" "repo" {
  name   = var.ecr_repo_name
}