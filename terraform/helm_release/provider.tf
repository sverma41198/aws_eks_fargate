data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

data "aws_ecr_authorization_token" "token" {
  registry_id = var.aws_acount_id 
}

provider "helm" {
  kubernetes {
    config_path=/home/.kubernetes/config
  }
  registry {
    url      = var.aws_ecr_id
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}