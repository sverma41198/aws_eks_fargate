resource "helm_release" "my_release" {
  name      = var.chart_release_name
  namespace = var.cluster_namespace
  create_namespace = true
  
  repository          = var.aws_ecr_id
  chart               = var.chat_name
  version             = var.chart_version
  
}