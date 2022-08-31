variable "kubernetes_config_path" {
  type        = string
  description = "The path to the Kubernetes config"
  default     = "~/.kube/config"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS Cluster"
}

variable "region" {
  type        = string
  description = "Region"
  default     = "us-west-2"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR range"
  default     = "10.0.0.0/16"
}

variable "eks_cluster_version" {
  type        = string
  description = "EKS Cluster Version"
  default     = "1.22"
}

variable "ng_instance_types" {
  type        = string
  description = "Node group instance types"
  default     = "t3.xlarge"
}

variable "ng_desired_size" {
  type        = string
  description = "Node group desired size"
  default     = "3"
}

variable "ng_max_size" {
  type        = string
  description = "Node group max size"
  default     = "4"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account id to use"
}

variable "create_cloudwatch_log_group" {
  type        = bool
  description = "Whether or not to create a CloudWatch log group"
  default     = false
}
