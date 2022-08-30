output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${data.aws_region.current.id} update-kubeconfig --name ${module.eks.cluster_id}"
}

output "kubernetes_host" {
  description = "Kubernetes endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "The CA certificate for the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_name" {
  description = "The name of the cluster"
  value       = module.eks.cluster_id
}

output "role_arn" {
  description = "The ARN of the assumable role"
  value       = module.iam_eks_role.iam_role_arn
}

output "role_name" {
  description = "The name of the assumable role"
  value       = module.iam_eks_role.iam_role_name
}